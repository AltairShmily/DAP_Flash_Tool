import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/collapsible_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  NavItem _selectedNav = NavItem.flash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedItem: _selectedNav,
            onItemSelected: (item) {
              setState(() => _selectedNav = item);
            },
          ),
          Expanded(
            child: Column(
              children: [
                // Title bar
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.usb, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'DAP Flash Tool',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      // Theme toggle
                      IconButton(
                        icon: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).setThemeMode(
                                themeMode == ThemeMode.dark
                                    ? ThemeMode.light
                                    : ThemeMode.dark,
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          setState(() => _selectedNav = NavItem.settings);
                        },
                      ),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: _buildContent(),
                ),
                // Status bar
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Status: Ready',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        'v0.1.0',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNav) {
      case NavItem.device:
        return _buildDevicePage();
      case NavItem.flash:
        return _buildFlashPage();
      case NavItem.pack:
        return _buildPackPage();
      case NavItem.history:
        return _buildHistoryPage();
      case NavItem.settings:
        return _buildSettingsPage();
    }
  }

  Widget _buildFlashPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CollapsibleCard(
            title: 'Connection',
            icon: Icons.usb,
            subtitle: 'No device connected',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Device connection settings will go here'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Devices'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CollapsibleCard(
            title: 'Flash Operation',
            icon: Icons.flash_on,
            subtitle: 'Ready',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select Firmware...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Chip(label: Text('HEX')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Target Chip',
                          border: OutlineInputBorder(),
                        ),
                        items: const [],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Start Address',
                    border: OutlineInputBorder(),
                    prefixText: '0x',
                  ),
                  initialValue: '08000000',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Flash'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Erase'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Chip ID'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CollapsibleCard(
            title: 'Output Log',
            icon: Icons.terminal,
            initiallyExpanded: true,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                '[14:23:01] Ready\n[14:23:02] Waiting for operation...',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePage() {
    return const Center(child: Text('Device Page - Coming Soon'));
  }

  Widget _buildPackPage() {
    return const Center(child: Text('Pack Management - Coming Soon'));
  }

  Widget _buildHistoryPage() {
    return const Center(child: Text('Flash History - Coming Soon'));
  }

  Widget _buildSettingsPage() {
    return const Center(child: Text('Settings - Coming Soon'));
  }
}
