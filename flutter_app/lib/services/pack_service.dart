import '../proto/dap_flash.pb.dart';
import '../proto/dap_flash.pbgrpc.dart';
import 'grpc_client.dart';

class PackService {
  final _client = GrpcClient.instance;

  Future<List<PackInfo>> listPacks() async {
    final response = await _client.stub.listPacks(ListProbesRequest());
    return response.packs;
  }

  Future<List<PackInfo>> searchPacks(String query) async {
    final response = await _client.stub.searchPacks(SearchRequest(query: query));
    return response.packs;
  }

  Stream<ProgressUpdate> downloadPack({
    required String packUrl,
    required String packName,
  }) async* {
    final call = _client.stub.downloadPack(DownloadRequest(
      packUrl: packUrl,
      packName: packName,
    ));

    await for (final update in call) {
      yield update;
    }
  }
}
