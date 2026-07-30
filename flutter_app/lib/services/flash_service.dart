import '../proto/dap_flash.pb.dart';
import '../proto/dap_flash.pbgrpc.dart';
import 'grpc_client.dart';

class FlashService {
  final _client = GrpcClient.instance;

  Stream<ProgressUpdate> flashFirmware({
    required String firmwarePath,
    required int startAddress,
    String driver = 'pyocd',
  }) async* {
    final call = _client.stub.flashFirmware(FlashRequest(
      firmwarePath: firmwarePath,
      startAddress: startAddress,
      driver: driver,
    ));

    await for (final update in call) {
      yield update;
    }
  }

  Stream<ProgressUpdate> eraseChip({String mode = 'chip'}) async* {
    final call = _client.stub.eraseChip(EraseRequest(mode: mode));

    await for (final update in call) {
      yield update;
    }
  }
}
