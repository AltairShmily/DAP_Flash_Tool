import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NavItem {
  device(Icons.usb, 'Device', '设备'),
  flash(Icons.flash_on, 'Flash', '烧录'),
  pack(Icons.inventory_2, 'Packs', 'Pack'),
  history(Icons.history, 'History', '历史'),
  settings(Icons.settings, 'Settings', '设置');

  final IconData icon;
  final String labelEn;
  final String labelZh;
  const NavItem(this.icon, this.labelEn, this.labelZh);

  String labelFor(String languageCode) {
    return languageCode == 'zh' ? labelZh : labelEn;
  }
}

class AppSidebar extends ConsumerWidget {
  final NavItem selectedItem;
  final ValueChanged<NavItem> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...NavItem.values.map((item) {
            final isSelected = item == selectedItem;
            final label = item.labelFor(locale.languageCode);
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
                          label,
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
