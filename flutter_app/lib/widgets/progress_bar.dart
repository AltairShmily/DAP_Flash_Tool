import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../l10n/app_strings.dart';

/// Icon/color for one phase of the flash operation. Labels are resolved at
/// build time from AppStrings so the indicator follows the app locale.
class _PhaseStyle {
  final IconData icon;
  final Color? color;

  const _PhaseStyle(this.icon, this.color);
}

const _phaseStyles = [
  _PhaseStyle(Icons.link, Colors.blue),
  _PhaseStyle(Icons.delete_sweep, Colors.orange),
  _PhaseStyle(Icons.memory, Colors.purple),
  _PhaseStyle(Icons.verified, Colors.teal),
  _PhaseStyle(Icons.restart_alt, Colors.green),
];

List<String> _phaseLabels(AppStrings strings) => [
      strings.phaseConnect,
      strings.phaseErase,
      strings.phaseProgram,
      strings.phaseVerify,
      strings.phaseReset,
    ];

class FlashProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? statusText;
  final String? speedText;
  final int currentPhase; // 0-based index into the 5 flash phases

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
    final labels = _phaseLabels(AppStrings.of(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Phase indicators ──
        Row(
          children: List.generate(_phaseStyles.length, (i) {
            final phase = _phaseStyles[i];
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
                      labels[i],
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
                    : _phaseStyles[currentPhase.clamp(0, _phaseStyles.length - 1)].color ??
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
                  Expanded(
                    child: Text(
                      statusText!,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
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
