import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'grpc_client.dart';

/// Singleton backend manager — shared across the app.
final backendManagerProvider = Provider<BackendManager>((ref) {
  return BackendManager();
});

/// Backend process lifecycle manager.
///
/// Resolution order for the backend:
/// 1. Bundled:  <exe_dir>/backend/server.exe        (release builds)
/// 2. Dev:      <repo_root>/backend/server.py       (found by walking up from
///              the executable directory, so the launch cwd does not matter)
///    executed with <repo_root>/backend/venv python when present, otherwise
///    system python.
///
/// Startup uses the backend's "READY <port>" stdout handshake instead of blind
/// port probing, so another process listening on 50051 can never be mistaken
/// for our backend.
class BackendManager {
  Process? _process;
  bool _isRunning = false;
  bool _processExited = false;
  String? _lastError;
  String? _serverScript;
  int _port = 50051;
  Completer<void>? _readyCompleter;
  final List<String> _stderrTail = [];

  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;

  bool get isRunning => _isRunning;
  String? get lastError => _lastError;
  int get port => _port;

  /// Detected backend mode — useful for the settings page.
  BackendMode _mode = BackendMode.notFound;
  BackendMode get mode => _mode;
  String? _resolvedPath;
  String? get resolvedPath => _resolvedPath;

  /// Never spawn processes under `flutter test`.
  static bool get _isTestEnvironment =>
      Platform.environment.containsKey('FLUTTER_TEST');

  /// Ensure the backend is running. Safe to call multiple times.
  /// Returns true if the backend is ready (or was already running).
  Future<bool> ensureRunning() async {
    if (_isTestEnvironment) {
      _lastError = 'Backend management is disabled under flutter test.';
      return false;
    }

    // Our own child process still alive and answering gRPC?
    if (_isRunning && _process != null && !_processExited) {
      if (await checkHealth()) return true;
      _isRunning = false;
    }

    _lastError = null;

    // An external backend (e.g. orphan from a previous run, or one started
    // manually) already answering gRPC on the default port?
    GrpcClient.instance.setPort(50051);
    if (await checkHealth()) {
      _isRunning = true;
      _port = 50051;
      if (_mode == BackendMode.notFound) {
        await _resolveBackend();
      }
      return true;
    }

    // Resolve and launch our own backend.
    _resolvedPath = await _resolveBackend();
    if (_resolvedPath == null) {
      _mode = BackendMode.notFound;
      _lastError =
          'Backend not found. Install Python 3.9+ or place server.exe in backend/.';
      return false;
    }

    try {
      await _launchBackend(_resolvedPath!);
    } catch (e) {
      _isRunning = false;
      _lastError = 'Failed to start backend: $e';
      return false;
    }

    // Wait for the READY handshake (falls back to gRPC health polling).
    final ready = _readyCompleter ?? Completer<void>();
    try {
      await ready.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // READY line missing (older backend?) — poll gRPC as fallback.
      for (var i = 0; i < 8; i++) {
        if (_processExited) break;
        if (await checkHealth()) {
          _isRunning = true;
          return true;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    if (_isRunning && await checkHealth()) {
      return true;
    }

    _isRunning = false;
    if (_processExited) {
      final tail = _stderrTail.isEmpty ? '' : '\n${_stderrTail.join('\n')}';
      _lastError = 'Backend process exited during startup.$tail';
    } else {
      _lastError = 'Backend did not become ready within 10 seconds.';
    }
    return false;
  }

  /// Resolve which backend to launch and how (absolute paths only).
  Future<String?> _resolveBackend() async {
    final sep = Platform.pathSeparator;
    final exeDir = File(Platform.resolvedExecutable).parent;

    // 1. Bundled PyInstaller exe (release builds)
    final bundledExe = '${exeDir.path}${sep}backend${sep}server.exe';
    if (await File(bundledExe).exists()) {
      _mode = BackendMode.bundled;
      _serverScript = null;
      return bundledExe;
    }

    // 2. Dev mode — walk up from the executable directory to find the repo
    //    root containing backend/server.py (cwd-independent).
    Directory? dir = exeDir;
    for (var i = 0; i < 8 && dir != null; i++) {
      final script = '${dir.path}${sep}backend${sep}server.py';
      if (await File(script).exists()) {
        _serverScript = script;
        final linuxVenv = '${dir.path}${sep}backend${sep}venv${sep}bin${sep}python';
        final winVenv =
            '${dir.path}${sep}backend${sep}venv${sep}Scripts${sep}python.exe';
        if (Platform.isLinux && await File(linuxVenv).exists()) {
          _mode = BackendMode.venv;
          return linuxVenv;
        }
        if (Platform.isWindows && await File(winVenv).exists()) {
          _mode = BackendMode.venv;
          return winVenv;
        }
        _mode = BackendMode.systemPython;
        return Platform.isWindows ? 'python' : 'python3';
      }
      dir = dir.parent;
    }

    _mode = BackendMode.notFound;
    return null;
  }

  Future<void> _launchBackend(String path) async {
    _processExited = false;
    _stderrTail.clear();
    _readyCompleter = Completer<void>();

    final args = _mode == BackendMode.bundled
        ? <String>['$_port']
        : <String>[_serverScript!, '$_port'];

    final process = await Process.start(
      path,
      args,
      mode: ProcessStartMode.normal,
      workingDirectory: _mode == BackendMode.bundled
          ? null
          : File(_serverScript!).parent.path,
    );
    _process = process;

    _stdoutSub = process.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(_handleStdoutLine);

    _stderrSub = process.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
      _stderrTail.add(line);
      if (_stderrTail.length > 20) {
        _stderrTail.removeAt(0);
      }
    });

    unawaited(process.exitCode.then((code) {
      _processExited = true;
      _isRunning = false;
      if (code != 0 && _lastError == null) {
        _lastError = 'Backend exited with code $code';
      }
      // Unblock a pending READY wait so ensureRunning can report failure.
      if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
        _readyCompleter!.completeError(
          TimeoutException('backend exited with code $code'),
        );
      }
    }));
  }

  void _handleStdoutLine(String line) {
    // Handshake protocol: the server prints "READY <port>" once listening.
    if (line.startsWith('READY ')) {
      final parsed = int.tryParse(line.substring(6).trim());
      if (parsed != null && parsed > 0) {
        _port = parsed;
        GrpcClient.instance.setPort(parsed);
      }
      _isRunning = true;
      if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
        _readyCompleter!.complete();
      }
    } else if (line.startsWith('ERROR')) {
      _stderrTail.add(line);
    }
  }

  Future<void> stop() async {
    final process = _process;
    _process = null;
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;

    if (process != null && !_processExited) {
      process.kill(ProcessSignal.sigterm);
      try {
        await process.exitCode.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
      } catch (_) {
        // Process already gone.
      }
    }
    _isRunning = false;
    _processExited = true;
    GrpcClient.instance.reset();
  }

  /// Full gRPC health check with a bounded timeout.
  Future<bool> checkHealth() async {
    try {
      return await GrpcClient.instance
          .checkConnection()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      return false;
    }
  }
}

/// How the backend was resolved — displayed in the settings page.
enum BackendMode {
  bundled,
  venv,
  systemPython,
  notFound,
}
