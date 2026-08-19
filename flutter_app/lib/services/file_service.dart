import 'package:fixnum/fixnum.dart';
import '../proto/dap_flash.pb.dart';
import 'grpc_client.dart';

class FileService {
  final _client = GrpcClient.instance;

  Future<PreviewResponse> previewFirmware({
    required String filePath,
    int offset = 0,
    int length = 256,
  }) async {
    return await _client.stub.previewFirmware(
      PreviewRequest()
        ..filePath = filePath
        ..offset = Int64(offset)
        ..length = length,
    );
  }

  Future<FileInfo> getFileInfo(String filePath) async {
    return await _client.stub.getFileInfo(
      PreviewRequest()..filePath = filePath,
    );
  }
}
