import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        AppStrings(const Locale('en'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'DAP Flash Tool',
      'device': 'Device',
      'flash': 'Flash',
      'packs': 'Packs',
      'history': 'History',
      'settings': 'Settings',
      'connection': 'Connection',
      'noDeviceConnected': 'No device connected',
      'refreshDevices': 'Refresh Devices',
      'flashOperation': 'Flash Operation',
      'ready': 'Ready',
      'selectFirmware': 'Select Firmware...',
      'targetChip': 'Target Chip',
      'startAddress': 'Start Address',
      'flashBtn': 'Flash',
      'eraseBtn': 'Erase',
      'resetBtn': 'Reset',
      'chipIdBtn': 'Chip ID',
      'outputLog': 'Output Log',
      'statusReady': 'Status: Ready',
      'theme': 'Theme',
      'darkMode': 'Dark',
      'lightMode': 'Light',
      'systemMode': 'System',
      'driver': 'Driver',
      'pyocd': 'PyOCD',
      'openocd': 'OpenOCD',
      'defaultFrequency': 'Default Frequency',
      'defaultProtocol': 'Default Protocol',
      'clearHistory': 'Clear History',
      'about': 'About',
      'version': 'Version',
      'packManagement': 'Pack Management',
      'installedPacks': 'Installed Packs',
      'searchChips': 'Search Chips...',
      'scanDirectory': 'Scan Directory',
      'noPacksFound': 'No packs found',
      'disconnect': 'Disconnect',
      'deviceConnected': 'Device Connected',
      'devicePage': 'Device Page - Coming Soon',
      'packPage': 'Pack Management - Coming Soon',
      'historyPage': 'Flash History - Coming Soon',
      'settingsPage': 'Settings - Coming Soon',
      'deviceConnSettings': 'Device connection settings will go here',
      'logReady': '[14:23:01] Ready\n[14:23:02] Waiting for operation...',
    },
    'zh': {
      'appTitle': 'DAP 烧录工具',
      'device': '设备',
      'flash': '烧录',
      'packs': 'Pack',
      'history': '历史',
      'settings': '设置',
      'connection': '连接',
      'noDeviceConnected': '未连接设备',
      'refreshDevices': '刷新设备列表',
      'flashOperation': '烧录操作',
      'ready': '就绪',
      'selectFirmware': '选择固件...',
      'targetChip': '目标芯片',
      'startAddress': '起始地址',
      'flashBtn': '烧录',
      'eraseBtn': '擦除',
      'resetBtn': '复位',
      'chipIdBtn': '芯片 ID',
      'outputLog': '输出日志',
      'statusReady': '状态: 就绪',
      'theme': '主题',
      'darkMode': '深色',
      'lightMode': '浅色',
      'systemMode': '跟随系统',
      'driver': '驱动',
      'pyocd': 'PyOCD',
      'openocd': 'OpenOCD',
      'defaultFrequency': '默认频率',
      'defaultProtocol': '默认协议',
      'clearHistory': '清除历史',
      'about': '关于',
      'version': '版本',
      'packManagement': 'Pack 管理',
      'installedPacks': '已安装 Pack',
      'searchChips': '搜索芯片...',
      'scanDirectory': '扫描目录',
      'noPacksFound': '未找到 Pack',
      'disconnect': '断开连接',
      'deviceConnected': '设备已连接',
      'devicePage': '设备页 - 即将推出',
      'packPage': 'Pack 管理 - 即将推出',
      'historyPage': '烧录历史 - 即将推出',
      'settingsPage': '设置 - 即将推出',
      'deviceConnSettings': '设备连接设置将在此处显示',
      'logReady': '[14:23:01] 就绪\n[14:23:02] 等待操作...',
    },
  };

  String _t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters
  String get appTitle => _t('appTitle');
  String get device => _t('device');
  String get flash => _t('flash');
  String get packs => _t('packs');
  String get history => _t('history');
  String get settings => _t('settings');
  String get connection => _t('connection');
  String get noDeviceConnected => _t('noDeviceConnected');
  String get refreshDevices => _t('refreshDevices');
  String get flashOperation => _t('flashOperation');
  String get ready => _t('ready');
  String get selectFirmware => _t('selectFirmware');
  String get targetChip => _t('targetChip');
  String get startAddress => _t('startAddress');
  String get flashBtn => _t('flashBtn');
  String get eraseBtn => _t('eraseBtn');
  String get resetBtn => _t('resetBtn');
  String get chipIdBtn => _t('chipIdBtn');
  String get outputLog => _t('outputLog');
  String get statusReady => _t('statusReady');
  String get theme => _t('theme');
  String get darkMode => _t('darkMode');
  String get lightMode => _t('lightMode');
  String get systemMode => _t('systemMode');
  String get driver => _t('driver');
  String get pyocd => _t('pyocd');
  String get openocd => _t('openocd');
  String get defaultFrequency => _t('defaultFrequency');
  String get defaultProtocol => _t('defaultProtocol');
  String get clearHistory => _t('clearHistory');
  String get about => _t('about');
  String get version => _t('version');
  String get packManagement => _t('packManagement');
  String get installedPacks => _t('installedPacks');
  String get searchChips => _t('searchChips');
  String get scanDirectory => _t('scanDirectory');
  String get noPacksFound => _t('noPacksFound');
  String get disconnect => _t('disconnect');
  String get deviceConnected => _t('deviceConnected');
  String get devicePage => _t('devicePage');
  String get packPage => _t('packPage');
  String get historyPage => _t('historyPage');
  String get settingsPage => _t('settingsPage');
  String get deviceConnSettings => _t('deviceConnSettings');
  String get logReady => _t('logReady');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
