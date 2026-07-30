import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/flash_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/sidebar.dart';
import '../widgets/collapsible_card.dart';
import 'pack_page.dart';
import 'settings_page.dart';

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
    final locale = ref.watch(localeProvider);
    final strings = AppStrings(locale);

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
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.usb, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        strings.appTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      // Language toggle
                      IconButton(
                        icon: Text(
                          locale.languageCode == 'zh' ? '中' : 'EN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        tooltip: locale.languageCode == 'zh' ? 'Switch to English' : '切换到中文',
                        onPressed: () {
                          ref.read(localeProvider.notifier).setLocale(
                            locale.languageCode == 'zh'
                                ? const Locale('en')
                                : const Locale('zh'),
                          );
                        },
                      ),
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
                  child: _buildContent(strings),
                ),
                // Status bar
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        strings.statusReady,
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

  Widget _buildContent(AppStrings strings) {
    switch (_selectedNav) {
      case NavItem.device:
        return _buildDevicePage(strings);
      case NavItem.flash:
        return _buildFlashPage(strings);
      case NavItem.pack:
        return _buildPackPage(strings);
      case NavItem.history:
        return _buildHistoryPage(strings);
      case NavItem.settings:
        return _buildSettingsPage(strings);
    }
  }

  Future<void> _pickFirmware() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin', 'hex', 'elf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final ext = file.extension?.toLowerCase() ?? '';
      String format;
      switch (ext) {
        case 'hex':
          format = 'HEX';
          break;
        case 'elf':
          format = 'ELF';
          break;
        case 'bin':
        default:
          format = 'BIN';
          break;
      }
      ref.read(flashProvider.notifier).setFirmware(file.path!, format);
    }
  }

  Widget _buildFlashPage(AppStrings strings) {
    final flashState = ref.watch(flashProvider);
    final firmwareName = flashState.firmwarePath != null
        ? flashState.firmwarePath!.split('/').last.split('\\').last
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CollapsibleCard(
            title: strings.connection,
            icon: Icons.usb,
            subtitle: strings.noDeviceConnected,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(strings.deviceConnSettings),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.refreshDevices),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CollapsibleCard(
            title: strings.flashOperation,
            icon: Icons.flash_on,
            subtitle: strings.ready,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFirmware,
                        icon: const Icon(Icons.folder_open),
                        label: Text(firmwareName ?? strings.selectFirmware),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text(flashState.firmwareFormat ?? '—')),
                  ],
                ),
                if (flashState.firmwarePath != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    flashState.firmwarePath!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: strings.targetChip,
                          border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: strings.startAddress,
                    border: const OutlineInputBorder(),
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
                        label: Text(strings.flashBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        label: Text(strings.eraseBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.restart_alt),
                        label: Text(strings.resetBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: Text(strings.chipIdBtn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CollapsibleCard(
              title: strings.outputLog,
              icon: Icons.terminal,
              initiallyExpanded: true,
              child: Container(
                constraints: const BoxConstraints(minHeight: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(
                    strings.logReady,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePage(AppStrings strings) {
    return Center(child: Text(strings.devicePage));
  }

  Widget _buildPackPage(AppStrings strings) {
    return const PackPage();
  }

  Widget _buildHistoryPage(AppStrings strings) {
    return Center(child: Text(strings.historyPage));
  }

  Widget _buildSettingsPage(AppStrings strings) {
    return const SettingsPage();
  }
}
