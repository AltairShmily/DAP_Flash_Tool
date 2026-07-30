import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Appearance ──
          CollapsibleCard(
            title: 'Appearance',
            icon: Icons.palette,
            subtitle: _themeModeLabel(themeMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Driver ──
          CollapsibleCard(
            title: 'Debug Driver',
            icon: Icons.build,
            subtitle: settings.driver == 'pyocd' ? 'PyOCD' : 'OpenOCD',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Debug Probe Driver', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('PyOCD'),
                  subtitle: const Text('ARM DAPLink debug probe driver'),
                  value: 'pyocd',
                  groupValue: settings.driver,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setDriver(v);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<String>(
                  title: const Text('OpenOCD'),
                  subtitle: const Text('Open On-Chip Debugger'),
                  value: 'openocd',
                  groupValue: settings.driver,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setDriver(v);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Defaults ──
          CollapsibleCard(
            title: 'Flash Defaults',
            icon: Icons.tune,
            subtitle: '${_freqLabel(settings.frequency)} · ${settings.protocol.toUpperCase()}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frequency dropdown
                Text('Default Frequency', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: settings.frequency,
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
                Text('Default Protocol', style: theme.textTheme.labelLarge),
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
            title: 'Flash History',
            icon: Icons.history,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final records = ref.watch(historyProvider);
                    return Text(
                      '${records.length} record${records.length == 1 ? '' : 's'} stored',
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
                        title: const Text('Clear History'),
                        content: const Text('This will permanently delete all flash history records. Continue?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(historyProvider.notifier).clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear History'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── About ──
          CollapsibleCard(
            title: 'About',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aboutRow('Application', 'DAP Flash Tool'),
                _aboutRow('Version', 'v0.1.0'),
                _aboutRow('Flutter', '3.x / Riverpod'),
                _aboutRow('Backend', 'Rust + gRPC'),
                const Divider(height: 24),
                Text(
                  'A cross-platform ARM chip flash tool powered by CMSIS-DAP debug probes. '
                  'Supports .pack chip database and HEX/BIN firmware files.',
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
                      'github.com/nousresearch/dap-flash-tool',
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

  static String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
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
