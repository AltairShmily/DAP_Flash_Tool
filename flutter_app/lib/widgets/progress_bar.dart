import 'package:flutter/material.dart';

class FlashProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? statusText;
  final String? speedText;

  const FlashProgressBar({
    super.key,
    required this.progress,
    this.statusText,
    this.speedText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? Colors.green
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (statusText != null || speedText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (statusText != null)
                  Text(
                    statusText!,
                    style: theme.textTheme.bodySmall,
                  ),
                if (speedText != null)
                  Text(
                    speedText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
