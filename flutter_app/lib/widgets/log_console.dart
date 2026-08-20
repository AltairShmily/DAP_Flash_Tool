import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;

  LogEntry({
    required this.message,
    this.level = LogLevel.info,
  }) : timestamp = DateTime.now();
}

enum LogLevel { info, success, warning, error }

class LogConsole extends StatelessWidget {
  final List<LogEntry> entries;

  const LogConsole({super.key, required this.entries});

  Color _getColor(LogLevel level, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (level) {
      case LogLevel.info:
        return isDark ? const Color(0xFFCDD6F4) : const Color(0xFF4C4F69);
      case LogLevel.success:
        return isDark ? const Color(0xFFA6E3A1) : const Color(0xFF386A20);
      case LogLevel.warning:
        return isDark ? const Color(0xFFFAB387) : const Color(0xFF7D5700);
      case LogLevel.error:
        return isDark ? const Color(0xFFF38BA8) : const Color(0xFFBA1A1A);
    }
  }

  IconData _getIcon(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.success:
        return Icons.check_circle_outline;
      case LogLevel.warning:
        return Icons.warning_amber_outlined;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monoFamily = AppTheme.monoFamily(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11111B) : const Color(0xFFE6E9EF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final timeStr =
              '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
              '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
              '${entry.timestamp.second.toString().padLeft(2, '0')}';
          final color = _getColor(entry.level, theme.brightness);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level icon
                Icon(_getIcon(entry.level), size: 14, color: color),
                const SizedBox(width: 4),
                // Timestamp
                Text(
                  '[$timeStr] ',
                  style: TextStyle(
                    color: _getColor(LogLevel.info, theme.brightness)
                        .withValues(alpha: 0.5),
                    fontFamily: monoFamily,
                    fontSize: 13,
                  ),
                ),
                // Message
                Expanded(
                  child: Text(
                    entry.message,
                    style: TextStyle(
                      color: color,
                      fontFamily: monoFamily,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
