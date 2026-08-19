import 'dart:io';
import 'grpc_client.dart';

class BackendManager {
  Process? _process;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;

    final backendPath = await _findBackendPath();
    if (backendPath == null) {
      throw Exception('Backend executable not found');
    }

    if (backendPath == 'python') {
      _process = await Process.start(
        'python',
        ['../backend/server.py', '50051'],
        mode: ProcessStartMode.inheritStdio,
      );
    } else if (backendPath.endsWith('.exe') && !backendPath.contains('server')) {
      // Bundled executable
      _process = await Process.start(
        backendPath,
        ['50051'],
        mode: ProcessStartMode.inheritStdio,
      );
    } else if (backendPath.contains('venv')) {
      // Venv python — needs server.py as argument
      _process = await Process.start(
        backendPath,
        ['../backend/server.py', '50051'],
        mode: ProcessStartMode.inheritStdio,
      );
    } else {
      // server.exe or other executable
      _process = await Process.start(
        backendPath,
        ['50051'],
        mode: ProcessStartMode.inheritStdio,
      );
    }

    _isRunning = true;

    await Future.delayed(const Duration(seconds: 2));

    if (_process != null) {
      _process!.exitCode.then((code) {
        _isRunning = false;
        print('Backend exited with code: $code');
      });
    }
  }

  Future<String?> _findBackendPath() async {
    final appDir = File(Platform.resolvedExecutable).parent;
    final bundledPath = '${appDir.path}${Platform.pathSeparator}backend${Platform.pathSeparator}server.exe';
    if (await File(bundledPath).exists()) {
      return bundledPath;
    }

    // Dev mode: look for backend/server.py and use venv python if available
    final devPath = '..${Platform.pathSeparator}backend${Platform.pathSeparator}server.py';
    if (await File(devPath).exists()) {
      // Try venv python first (more reliable for dependencies)
      final venvPython = '..${Platform.pathSeparator}backend${Platform.pathSeparator}venv${Platform.pathSeparator}bin${Platform.pathSeparator}python';
      if (Platform.isLinux && await File(venvPython).exists()) {
        return venvPython;
      }
      final venvPythonWin = '..${Platform.pathSeparator}backend${Platform.pathSeparator}venv${Platform.pathSeparator}Scripts${Platform.pathSeparator}python.exe';
      if (Platform.isWindows && await File(venvPythonWin).exists()) {
        return venvPythonWin;
      }
      return 'python';
    }

    return null;
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
