import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:iconsax/iconsax.dart';

class AppTitleBar extends StatelessWidget {
  final String title;

  const AppTitleBar({super.key, this.title = 'DAP Flash Tool'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // ── App icon + title ──
          const SizedBox(width: 12),
          Icon(Iconsax.flash_15, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),

          // ── Drag area ──
          Expanded(
            child: MoveWindow(
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── Window buttons ──
          _WindowButtons(cs: cs),
        ],
      ),
    );
  }
}

class _WindowButtons extends StatelessWidget {
  final ColorScheme cs;
  const _WindowButtons({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minimize
        _WindowButton(
          icon: Iconsax.minus_cirlce,
          color: cs.onSurfaceVariant,
          onTap: () => appWindow.minimize(),
        ),
        // Maximize / Restore
        _WindowButton(
          icon: appWindow.isMaximized ? Iconsax.maximize_1 : Iconsax.maximize,
          color: cs.onSurfaceVariant,
          onTap: () {
            appWindow.isMaximized
                ? appWindow.restore()
                : appWindow.maximize();
          },
        ),
        // Close
        _WindowButton(
          icon: Iconsax.close_circle,
          color: cs.error,
          onTap: () => appWindow.close(),
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WindowButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 36,
          height: 36,
          color: _hovering
              ? widget.color.withValues(alpha: 0.1)
              : Colors.transparent,
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}
