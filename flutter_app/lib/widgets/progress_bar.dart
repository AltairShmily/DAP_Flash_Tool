import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// Represents one phase of the flash operation.
class FlashPhase {
  final String label;
  final IconData icon;
  final Color? color;

  const FlashPhase({required this.label, required this.icon, this.color});
}

/// Default phases for a flash operation.
const defaultFlashPhases = [
  FlashPhase(label: '连接', icon: Icons.link, color: Colors.blue),
  FlashPhase(label: '擦除', icon: Icons.delete_sweep, color: Colors.orange),
  FlashPhase(label: '编程', icon: Icons.memory, color: Colors.purple),
  FlashPhase(label: '验证', icon: Icons.verified, color: Colors.teal),
  FlashPhase(label: '复位', icon: Icons.restart_alt, color: Colors.green),
];

class FlashProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? statusText;
  final String? speedText;
  final int currentPhase; // 0-based index into defaultFlashPhases

  const FlashProgressBar({
    super.key,
    required this.progress,
    this.statusText,
    this.speedText,
    this.currentPhase = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Phase indicators ──
        Row(
          children: List.generate(defaultFlashPhases.length, (i) {
            final phase = defaultFlashPhases[i];
            final isActive = i == currentPhase && !isComplete;
            final isDone = i < currentPhase || isComplete;

            return Expanded(
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : phase.icon,
                    size: 14,
                    color: isDone
                        ? Colors.green
                        : isActive
                            ? phase.color ?? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      phase.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDone
                            ? Colors.green
                            : isActive
                                ? phase.color ?? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.4),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),

        // ── Progress bar ──
        Row(
          children: [
            Expanded(
              child: LinearPercentIndicator(
                percent: progress.clamp(0.0, 1.0),
                lineHeight: 10,
                barRadius: const Radius.circular(5),
                backgroundColor: colorScheme.surfaceContainerHighest,
                progressColor: isComplete
                    ? Colors.green
                    : defaultFlashPhases[currentPhase.clamp(0, defaultFlashPhases.length - 1)].color ??
                        colorScheme.primary,
                animation: true,
                animateFromLastPercent: true,
                animationDuration: 300,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),

        // ── Status / speed ──
        if (statusText != null || speedText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (statusText != null)
                  Text(statusText!, style: theme.textTheme.bodySmall),
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
