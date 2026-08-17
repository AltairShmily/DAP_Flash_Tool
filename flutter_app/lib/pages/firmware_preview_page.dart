import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

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
              child: Text('文件: $_filePath'),
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
                    onPressed: _nextPage,
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
      });
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    if (_filePath == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement gRPC call to preview firmware
      // For now, show a placeholder
      setState(() {
        _hexDump = '预览功能待实现\n文件: $_filePath\n偏移: 0x${_offset.toRadixString(16).toUpperCase()}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hexDump = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  void _previousPage() {
    setState(() {
      _offset = (_offset - _length).clamp(0, double.maxFinite.toInt());
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
