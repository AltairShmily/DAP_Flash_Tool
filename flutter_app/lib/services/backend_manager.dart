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

  /// Ensure the backend is running. Safe to call multiple times.
  Future<void> ensureRunning() async {
    if (_isRunning) return;

    // First check if something is already listening on the port.
    final alreadyAlive = await _probeGrpc();
    if (alreadyAlive) {
      _isRunning = true;
      if (_mode == BackendMode.notFound) {
        // External backend — resolve mode for display purposes.
        await _resolveBackend();
      }
      return;
    }

    // Resolve and launch.
    _resolvedPath = await _resolveBackend();
    if (_resolvedPath == null) {
      _mode = BackendMode.notFound;
      return; // Don't throw — let the UI show the missing-backend card.
    }

    try {
      _process = await _launchBackend(_resolvedPath!);
    } catch (e) {
      _isRunning = false;
      return;
    }

    _isRunning = true;

    // Wait for gRPC to become available (up to 5 s).
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (await _probeGrpc()) return;
    }

    // If it still isn't up, check if the process exited.
    if (_process != null) {
      _process!.exitCode.then((code) {
        _isRunning = false;
      });
    }
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
      // Standalone exe — detached to avoid a visible console window.
      return Process.start(
        path,
        ['50051'],
        mode: ProcessStartMode.detached,
      );
    }

    // Python modes — need server.py as argument.
    // Keep inheritStdio so dev-mode errors are visible.
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
  /// PyInstaller standalone exe bundled with the app.
  bundled,

  /// Python from a virtualenv (dev mode).
  venv,

  /// System python on PATH (fallback).
  systemPython,

  /// No backend found at all.
  notFound,
}
