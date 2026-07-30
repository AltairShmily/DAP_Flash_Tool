import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/log_console.dart';

class LogNotifier extends StateNotifier<List<LogEntry>> {
  LogNotifier() : super([]);

  void info(String message) {
    state = [...state, LogEntry(message: message, level: LogLevel.info)];
  }

  void success(String message) {
    state = [...state, LogEntry(message: message, level: LogLevel.success)];
  }

  void warning(String message) {
    state = [...state, LogEntry(message: message, level: LogLevel.warning)];
  }

  void error(String message) {
    state = [...state, LogEntry(message: message, level: LogLevel.error)];
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
