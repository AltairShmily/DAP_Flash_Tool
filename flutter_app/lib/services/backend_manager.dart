import 'dart:io';
import 'grpc_client.dart';

/// Backend process lifecycle manager.
///
/// Search order for the backend executable:
/// 1. Bundled:  <app_dir>/backend/server.exe   (CI / release build)
/// 2. Dev venv: ../backend/venv/bin/python      (Linux dev)
/// 3. Dev venv: ../backend/venv/Scripts/python.exe (Windows dev)
/// 4. System:   python on PATH                  (fallback)
class BackendManager {
  Process? _process;
  bool _isRunning = false;
  String? _lastError;

  bool get isRunning => _isRunning;
  String? get lastError => _lastError;

  /// Detected backend mode — useful for the settings page.
  BackendMode _mode = BackendMode.notFound;
  BackendMode get mode => _mode;
  String? _resolvedPath;
  String? get resolvedPath => _resolvedPath;

  /// Ensure the backend is running. Safe to call multiple times.
  /// Returns true if the backend is ready (or was already running).
  Future<bool> ensureRunning() async {
    if (_isRunning) {
      // Double-check: is the port actually open?
      if (await _probeGrpc()) return true;
      // Stale state — reset and try again.
      _isRunning = false;
    }

    _lastError = null;

    // First check if something is already listening on the port.
    final alreadyAlive = await _probeGrpc();
    if (alreadyAlive) {
      _isRunning = true;
      if (_mode == BackendMode.notFound) {
        await _resolveBackend();
      }
      return true;
    }

    // Resolve and launch.
    _resolvedPath = await _resolveBackend();
    if (_resolvedPath == null) {
      _mode = BackendMode.notFound;
      _lastError = 'Backend not found. Install Python 3.9+ or place server.exe in backend/.';
      return false;
    }

    try {
      _process = await _launchBackend(_resolvedPath!);
    } catch (e) {
      _isRunning = false;
      _lastError = 'Failed to start backend: $e';
      return false;
    }

    // Wait for gRPC to become available (up to 8 s).
    for (var i = 0; i < 16; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (await _probeGrpc()) {
        _isRunning = true;
        // Reset the gRPC channel so the first real RPC goes through a fresh connection.
        GrpcClient.instance.reset();
        return true;
      }
    }

    // Timeout — check if the process exited.
    _isRunning = false;
    if (_process != null) {
      try {
        final exitCode = await _process!.exitCode.timeout(
          const Duration(seconds: 1),
          onTimeout: () => -1,
        );
        _lastError = 'Backend process exited with code $exitCode within startup timeout.';
      } catch (_) {
        _lastError = 'Backend did not respond on port 50051 within 8 seconds.';
      }
    }
    return false;
  }

  /// Resolve which backend to launch and how.
  Future<String?> _resolveBackend() async {
    final appDir = File(Platform.resolvedExecutable).parent;
    final sep = Platform.pathSeparator;

    // 1. Bundled PyInstaller exe (CI / release)
    final bundledExe = '${appDir.path}${sep}backend${sep}server.exe';
    if (await File(bundledExe).exists()) {
      _mode = BackendMode.bundled;
      return bundledExe;
    }

    // 2–3. Dev mode — look for venv python
    final devScript = '..${sep}backend${sep}server.py';
    if (await File(devScript).exists()) {
      // Linux venv
      final linuxVenv = '..${sep}backend${sep}venv${sep}bin${sep}python';
      if (Platform.isLinux && await File(linuxVenv).exists()) {
        _mode = BackendMode.venv;
        return linuxVenv;
      }
      // Windows venv
      final winVenv = '..${sep}backend${sep}venv${sep}Scripts${sep}python.exe';
      if (Platform.isWindows && await File(winVenv).exists()) {
        _mode = BackendMode.venv;
        return winVenv;
      }
      // 4. System python fallback
      _mode = BackendMode.systemPython;
      return 'python';
    }

    _mode = BackendMode.notFound;
    return null;
  }

  Future<Process> _launchBackend(String path) async {
    final sep = Platform.pathSeparator;

    if (_mode == BackendMode.bundled) {
      return Process.start(
        path,
        ['50051'],
        mode: ProcessStartMode.detached,
      );
    }

    // Python modes — need server.py as argument.
    final script = '..${sep}backend${sep}server.py';
    return Process.start(
      path,
      [script, '50051'],
      mode: ProcessStartMode.inheritStdio,
    );
  }

  Future<void> stop() async {
    if (_process != null) {
      _process!.kill(ProcessSignal.sigterm);
      await _process!.exitCode;
      _process = null;
      _isRunning = false;
      GrpcClient.instance.reset();
    }
  }

  /// Quick TCP probe to see if gRPC port is already open.
  Future<bool> _probeGrpc() async {
    try {
      final socket = await Socket.connect('127.0.0.1', 50051,
          timeout: const Duration(seconds: 1));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Full gRPC health check (used by the settings page).
  Future<bool> checkHealth() async {
    try {
      return await GrpcClient.instance.checkConnection();
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
