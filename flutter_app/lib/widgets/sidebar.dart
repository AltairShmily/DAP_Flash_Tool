import 'package:flutter/material.dart';

enum NavItem {
  device(Icons.usb, 'Device'),
  flash(Icons.flash_on, 'Flash'),
  pack(Icons.inventory_2, 'Packs'),
  history(Icons.history, 'History'),
  settings(Icons.settings, 'Settings');

  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class AppSidebar extends StatelessWidget {
  final NavItem selectedItem;
  final ValueChanged<NavItem> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...NavItem.values.map((item) {
            final isSelected = item == selectedItem;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Material(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onItemSelected(item),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
