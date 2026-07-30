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
    } else {
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

    final devPath = '..${Platform.pathSeparator}backend${Platform.pathSeparator}server.py';
    if (await File(devPath).exists()) {
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
