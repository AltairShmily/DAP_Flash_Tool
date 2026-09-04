import '../proto/dap_flash.pb.dart';
import 'grpc_client.dart';

/// Flash history is persisted by the backend (~/.dap_flash_tool/flash_history.json)
/// so records survive app restarts and include hash/chip/probe/duration.
class HistoryService {
  final _client = GrpcClient.instance;

  Future<List<FlashRecord>> getFlashHistory() async {
    final response = await _client.stub.getFlashHistory(GetFlashHistoryRequest());
    return response.records;
  }

  Future<OperationResult> clearFlashHistory() async {
    return await _client.stub.clearFlashHistory(ClearFlashHistoryRequest());
  }
}
