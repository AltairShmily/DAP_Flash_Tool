import 'package:grpc/grpc.dart';
import '../proto/dap_flash.pbgrpc.dart';

class GrpcClient {
  static GrpcClient? _instance;
  ClientChannel? _channel;
  DapFlashServiceClient? _stub;

  GrpcClient._();

  static GrpcClient get instance {
    _instance ??= GrpcClient._();
    return _instance!;
  }

  /// Lazily create (or recreate) the channel + stub.
  void _ensureChannel() {
    if (_channel != null) return;
    _channel = ClientChannel(
      '127.0.0.1',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        idleTimeout: Duration(minutes: 5),
      ),
    );
    _stub = DapFlashServiceClient(_channel!);
  }

  DapFlashServiceClient get stub {
    _ensureChannel();
    return _stub!;
  }

  /// Force-recreate the channel (call after backend restarts).
  void reset() {
    _channel?.shutdown();
    _channel = null;
    _stub = null;
  }

  Future<bool> checkConnection() async {
    try {
      _ensureChannel();
      await _stub!.listProbes(ListProbesRequest());
      return true;
    } catch (e) {
      // If the channel is in a bad state, reset it for next attempt.
      reset();
      return false;
    }
  }

  Future<void> shutdown() async {
    await _channel?.shutdown();
    _channel = null;
    _stub = null;
    _instance = null;
  }
}
