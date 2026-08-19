import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_service.dart';

class FirmwarePreviewPage extends ConsumerStatefulWidget {
  const FirmwarePreviewPage({super.key});

  @override
  ConsumerState<FirmwarePreviewPage> createState() => _FirmwarePreviewPageState();
}

class _FirmwarePreviewPageState extends ConsumerState<FirmwarePreviewPage> {
  String? _filePath;
  String _hexDump = '';
  int _offset = 0;
  final int _length = 256;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalSize = 0;
  String _fileFormat = '';
  final FileService _fileService = FileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('固件预览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: _pickFile,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_filePath != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('文件: $_filePath'),
                  if (_fileFormat.isNotEmpty)
                    Text(
                      '格式: $_fileFormat  |  大小: $_totalSize 字节  |  偏移: 0x${_offset.toRadixString(16).toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _hexDump,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          if (_filePath != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _offset > 0 ? _previousPage : null,
                    child: const Text('上一页'),
                  ),
                  const SizedBox(width: 16),
                  Text('偏移: 0x${_offset.toRadixString(16).toUpperCase()}'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _totalSize > 0 && _offset + _length < _totalSize
                        ? _nextPage
                        : null,
                    child: const Text('下一页'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hex', 'bin'],
    );
    if (result != null) {
      final file = result.files.first;
      setState(() {
        _filePath = file.path;
        _offset = 0;
        _errorMessage = null;
      });
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final preview = await _fileService.previewFirmware(
        filePath: _filePath!,
        offset: _offset,
        length: _length,
      );
      setState(() {
        _hexDump = preview.hexDump;
        _totalSize = preview.totalSize.toInt();
        _fileFormat = preview.fileFormat;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _hexDump = '';
        _isLoading = false;
      });
    }
  }

  void _previousPage() {
    setState(() {
      _offset = (_offset - _length).clamp(0, 1 << 32);
    });
    _loadPreview();
  }

  void _nextPage() {
    setState(() {
      _offset += _length;
    });
    _loadPreview();
  }
}
