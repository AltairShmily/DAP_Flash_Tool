import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proto/dap_flash.pb.dart' as pb;
import '../services/history_service.dart';

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

  factory FlashRecord.fromProto(pb.FlashRecord r) => FlashRecord(
        firmwarePath: r.firmwarePath,
        firmwareHash: r.firmwareHash,
        chipName: r.chipName,
        probeName: r.probeName,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(r.timestamp.toInt() * 1000),
        success: r.success,
        durationMs: r.durationMs.toInt(),
        errorMessage: r.errorMessage.isEmpty ? null : r.errorMessage,
      );
}

/// History is persisted by the backend (~/.dap_flash_tool/flash_history.json),
/// which records hash/chip/probe/duration during each flash. The frontend is
/// a read-through view: refresh() after operations, clearHistory() via RPC.
class HistoryNotifier extends StateNotifier<List<FlashRecord>> {
  final HistoryService _service = HistoryService();

  HistoryNotifier() : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final records = await _service.getFlashHistory();
      if (mounted) {
        state = records.map(FlashRecord.fromProto).toList();
      }
    } catch (_) {
      // Backend unavailable — keep whatever we already have.
    }
  }

  Future<bool> clearHistory() async {
    try {
      final result = await _service.clearFlashHistory();
      if (result.success && mounted) {
        state = [];
      }
      return result.success;
    } catch (_) {
      return false;
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<FlashRecord>>(
  (ref) => HistoryNotifier(),
);
