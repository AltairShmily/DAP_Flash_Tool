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

  bool get isRunning => _isRunning;

  /// Detected backend mode — useful for the settings page.
  BackendMode _mode = BackendMode.notFound;
  BackendMode get mode => _mode;
  String? _resolvedPath;
  String? get resolvedPath => _resolvedPath;

  Future<void> start() async {
    if (_isRunning) return;

    _resolvedPath = await _resolveBackend();
    if (_resolvedPath == null) {
      _mode = BackendMode.notFound;
      throw Exception(
        'Backend not found. Install Python 3.9+ with pyocd, '
        'or place server.exe in the backend/ directory next to the app.',
      );
    }

    _process = await _launchBackend(_resolvedPath!);
    _isRunning = true;

    // Wait briefly for the gRPC server to bind.
    await Future.delayed(const Duration(seconds: 2));

    _process!.exitCode.then((code) {
      _isRunning = false;
      print('Backend exited with code: $code');
    });
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
      // Standalone exe — no script argument needed
      return Process.start(path, ['50051'],
          mode: ProcessStartMode.inheritStdio);
    }

    // Python modes — need server.py as argument
    final script = '..${sep}backend${sep}server.py';
    return Process.start(path, [script, '50051'],
        mode: ProcessStartMode.inheritStdio);
  }

  Future<void> stop() async {
    if (_process != null) {
      _process!.kill(ProcessSignal.sigterm);
      await _process!.exitCode;
      _process = null;
      _isRunning = false;
    }
  }

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
  /// PyInstaller standalone exe bundled with the app.
  bundled,

  /// Python from a virtualenv (dev mode).
  venv,

  /// System python on PATH (fallback).
  systemPython,

  /// No backend found at all.
  notFound,
}
