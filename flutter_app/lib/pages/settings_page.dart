import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/collapsible_card.dart';

// ── Settings state providers ──

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

class AppSettings {
  final String driver;       // 'pyocd' or 'openocd'
  final String frequency;    // '1000', '2000', '4000', '8000'
  final String protocol;     // 'swd' or 'jtag'

  const AppSettings({
    this.driver = 'pyocd',
    this.frequency = '4000',
    this.protocol = 'swd',
  });

  AppSettings copyWith({String? driver, String? frequency, String? protocol}) {
    return AppSettings(
      driver: driver ?? this.driver,
      frequency: frequency ?? this.frequency,
      protocol: protocol ?? this.protocol,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      driver: prefs.getString('driver') ?? 'pyocd',
      frequency: prefs.getString('frequency') ?? '4000',
      protocol: prefs.getString('protocol') ?? 'swd',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver', state.driver);
    await prefs.setString('frequency', state.frequency);
    await prefs.setString('protocol', state.protocol);
  }

  void setDriver(String driver) {
    state = state.copyWith(driver: driver);
    _save();
  }

  void setFrequency(String freq) {
    state = state.copyWith(frequency: freq);
    _save();
  }

  void setProtocol(String protocol) {
    state = state.copyWith(protocol: protocol);
    _save();
  }
}

// ── Settings Page ──

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final strings = AppStrings.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Appearance ──
          CollapsibleCard(
            title: strings.appearance,
            icon: Icons.palette,
            subtitle: _themeModeLabel(themeMode, strings),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.theme, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(strings.systemMode),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(strings.lightMode),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(strings.darkMode),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                  },
                ),
                const SizedBox(height: 16),
                // Language
                Text('语言', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final locale = ref.watch(localeProvider);
                    return DropdownButtonFormField<String>(
                      initialValue: locale.languageCode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'zh', child: Text('中文')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(v));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Driver ──
          CollapsibleCard(
            title: strings.debugDriver,
            icon: Icons.build,
            subtitle: settings.driver == 'pyocd' ? strings.pyocd : strings.openocd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.selectDebugDriver, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: settings.driver,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setDriver(v);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(strings.pyocd),
                        subtitle: Text(strings.pyocdSubtitle),
                        value: 'pyocd',
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      RadioListTile<String>(
                        title: Text(strings.openocd),
                        subtitle: Text(strings.openocdSubtitle),
                        value: 'openocd',
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Defaults ──
          CollapsibleCard(
            title: strings.flashDefaults,
            icon: Icons.tune,
            subtitle: '${_freqLabel(settings.frequency)} · ${settings.protocol.toUpperCase()}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frequency dropdown
                Text(strings.defaultFrequency, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: settings.frequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: '1000', child: Text('1 MHz')),
                    DropdownMenuItem(value: '2000', child: Text('2 MHz')),
                    DropdownMenuItem(value: '4000', child: Text('4 MHz')),
                    DropdownMenuItem(value: '8000', child: Text('8 MHz')),
                  ],
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setFrequency(v);
                  },
                ),
                const SizedBox(height: 16),

                // Protocol radio
                Text(strings.defaultProtocol, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'swd',
                      label: Text('SWD'),
                      icon: Icon(Icons.cable),
                    ),
                    ButtonSegment(
                      value: 'jtag',
                      label: Text('JTAG'),
                      icon: Icon(Icons.device_hub),
                    ),
                  ],
                  selected: {settings.protocol},
                  onSelectionChanged: (protocols) {
                    ref.read(settingsProvider.notifier).setProtocol(protocols.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── History ──
          CollapsibleCard(
            title: strings.flashHistory,
            icon: Icons.history,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final records = ref.watch(historyProvider);
                    return Text(
                      '${records.length} ${strings.recordsStored}',
                      style: theme.textTheme.bodyMedium,
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(strings.clearHistory),
                        content: Text(strings.clearHistoryConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(strings.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(strings.clear)),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(historyProvider.notifier).clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.historyCleared)),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(strings.clearHistory),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── About ──
          CollapsibleCard(
            title: strings.about,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aboutRow(strings.application, 'DAP Flash Tool'),
                _aboutRow(strings.version, 'v0.1.0'),
                _aboutRow('Flutter', '3.x / Riverpod'),
                _aboutRow('Backend', 'Python + gRPC'),
                const Divider(height: 24),
                Text(
                  strings.aboutDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.code, size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      'github.com/AltairShmily/DAP_Flash_Tool',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static String _themeModeLabel(ThemeMode mode, AppStrings strings) {
    switch (mode) {
      case ThemeMode.light:
        return strings.lightMode;
      case ThemeMode.dark:
        return strings.darkMode;
      case ThemeMode.system:
        return strings.systemMode;
    }
  }

  static String _freqLabel(String freq) {
    switch (freq) {
      case '1000':
        return '1 MHz';
      case '2000':
        return '2 MHz';
      case '4000':
        return '4 MHz';
      case '8000':
        return '8 MHz';
      default:
        return '$freq kHz';
    }
  }

  static Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
