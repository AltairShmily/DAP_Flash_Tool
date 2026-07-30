import '../proto/dap_flash.pb.dart';
import '../proto/dap_flash.pbgrpc.dart';
import 'grpc_client.dart';

class DeviceService {
  final _client = GrpcClient.instance;

  Future<List<Probe>> listProbes() async {
    final response = await _client.stub.listProbes(ListProbesRequest());
    return response.probes;
  }

  Future<ConnectResponse> connect({
    required String probeId,
    required String target,
    required int frequency,
    required String protocol,
  }) async {
    return await _client.stub.connectProbe(ConnectRequest(
      probeId: probeId,
      target: target,
      frequency: frequency,
      protocol: protocol,
    ));
  }

  Future<void> disconnect() async {
    await _client.stub.disconnectProbe(DisconnectProbeRequest());
  }

  Future<OperationResult> reset() async {
    return await _client.stub.resetTarget(ResetTargetRequest());
  }

  Future<ChipIdResult> readChipId() async {
    return await _client.stub.readChipId(ReadChipIdRequest());
  }
}
