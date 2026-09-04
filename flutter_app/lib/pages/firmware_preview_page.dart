import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_strings.dart';
import '../services/file_service.dart';

class FirmwarePreviewPage extends ConsumerStatefulWidget {
  /// Optional firmware path to preview immediately (e.g. from the flash page).
  final String? initialPath;

  const FirmwarePreviewPage({super.key, this.initialPath});

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
  void initState() {
    super.initState();
    final initial = widget.initialPath;
    if (initial != null && initial.isNotEmpty) {
      _filePath = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreview());
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.previewTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            tooltip: strings.selectFirmware,
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
                  Text('${strings.fileLabel}: $_filePath'),
                  if (_fileFormat.isNotEmpty)
                    Text(
                      '${strings.formatLabel}: $_fileFormat  |  '
                      '${strings.sizeLabel}: $_totalSize  |  '
                      '${strings.offsetLabel}: 0x${_offset.toRadixString(16).toUpperCase()}',
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
                    child: Text(strings.prevPage),
                  ),
                  const SizedBox(width: 16),
                  Text('${strings.offsetLabel}: 0x${_offset.toRadixString(16).toUpperCase()}'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _totalSize > 0 && _offset + _length < _totalSize
                        ? _nextPage
                        : null,
                    child: Text(strings.nextPage),
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
      allowedExtensions: ['hex', 'bin', 'elf'],
    );
    if (result != null && result.files.isNotEmpty) {
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
      if (!mounted) return;
      setState(() {
        _hexDump = preview.hexDump;
        _totalSize = preview.totalSize.toInt();
        _fileFormat = preview.fileFormat;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${AppStrings.of(context).loadFailed}: $e';
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
