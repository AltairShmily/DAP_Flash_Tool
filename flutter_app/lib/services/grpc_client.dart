import 'package:grpc/grpc.dart';
import '../proto/dap_flash.pbgrpc.dart';

class GrpcClient {
  static GrpcClient? _instance;
  late ClientChannel _channel;
  late DapFlashServiceClient _stub;

  GrpcClient._() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub = DapFlashServiceClient(_channel);
  }

  static GrpcClient get instance {
    _instance ??= GrpcClient._();
    return _instance!;
  }

  DapFlashServiceClient get stub => _stub;

  Future<bool> checkConnection() async {
    try {
      await _stub.listProbes(ListProbesRequest());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
    _instance = null;
  }
}
