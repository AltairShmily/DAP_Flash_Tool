import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class FlashRecord {
  final String firmwarePath;
  final String firmwareHash;
  final String chipName;
  final String probeName;
  final DateTime timestamp;
  final bool success;
  final int durationMs;
  final String? errorMessage;

  FlashRecord({
    required this.firmwarePath,
    required this.firmwareHash,
    required this.chipName,
    required this.probeName,
    required this.timestamp,
    required this.success,
    required this.durationMs,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'firmwarePath': firmwarePath,
        'firmwareHash': firmwareHash,
        'chipName': chipName,
        'probeName': probeName,
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'durationMs': durationMs,
        'errorMessage': errorMessage,
      };

  factory FlashRecord.fromJson(Map<String, dynamic> json) => FlashRecord(
        firmwarePath: json['firmwarePath'] ?? '',
        firmwareHash: json['firmwareHash'] ?? '',
        chipName: json['chipName'] ?? '',
        probeName: json['probeName'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
        success: json['success'] ?? false,
        durationMs: json['durationMs'] ?? 0,
        errorMessage: json['errorMessage'],
      );
}

class HistoryNotifier extends StateNotifier<List<FlashRecord>> {
  static const _maxRecords = 100;

  HistoryNotifier() : super([]) {
    _load();
  }

  Future<String> get _historyPath async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}${Platform.pathSeparator}history.json';
  }

  Future<void> _load() async {
    try {
      final path = await _historyPath;
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> json = jsonDecode(content);
        state = json.map((e) => FlashRecord.fromJson(e)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<void> _save() async {
    final path = await _historyPath;
    final file = File(path);
    final json = state.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  void addRecord(FlashRecord record) {
    state = [record, ...state];
    if (state.length > _maxRecords) {
      state = state.sublist(0, _maxRecords);
    }
    _save();
  }

  void clearHistory() {
    state = [];
    _save();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<FlashRecord>>(
  (ref) => HistoryNotifier(),
);
