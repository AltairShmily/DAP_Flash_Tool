import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/log_console.dart';

class LogNotifier extends StateNotifier<List<LogEntry>> {
  /// Bound memory on long sessions: oldest entries are dropped first.
  static const int maxEntries = 2000;

  LogNotifier() : super([]);

  void _append(LogEntry entry) {
    final next = [...state, entry];
    state = next.length > maxEntries
        ? next.sublist(next.length - maxEntries)
        : next;
  }

  void info(String message) {
    _append(LogEntry(message: message, level: LogLevel.info));
  }

  void success(String message) {
    _append(LogEntry(message: message, level: LogLevel.success));
  }

  void warning(String message) {
    _append(LogEntry(message: message, level: LogLevel.warning));
  }

  void error(String message) {
    _append(LogEntry(message: message, level: LogLevel.error));
  }

  void add(String message, {bool isError = false}) {
    if (isError) {
      error(message);
    } else {
      info(message);
    }
  }

  void clear() {
    state = [];
  }
}

final logProvider = StateNotifierProvider<LogNotifier, List<LogEntry>>(
  (ref) => LogNotifier(),
);
