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
      // Home page placeholders
      'devicePage': 'Device Page - Coming Soon',
      'packPage': 'Pack Management - Coming Soon',
      'historyPage': 'Flash History - Coming Soon',
      'settingsPage': 'Settings - Coming Soon',
      'deviceConnSettings': 'Device connection settings will go here',
      'logReady': '[14:23:01] Ready\n[14:23:02] Waiting for operation...',
      // Pack page
      'searchPacksOrChips': 'Search packs or chips...',
      'importPack': 'Import Pack',
      'refresh': 'Refresh',
      'noPacksInstalled': 'No packs installed',
      'noPacksMatchSearch': 'No packs match your search',
      'scanOrImportHint': 'Scan a directory or import a .pack file to get started',
      'tryDifferentSearch': 'Try a different search term',
      'packsLoaded': 'packs loaded',
      'chipsIn': 'Chips in',
      'chips': 'chips',
      // Settings page
      'appearance': 'Appearance',
      'debugDriver': 'Debug Driver',
      'selectDebugDriver': 'Select Debug Probe Driver',
      'pyocdSubtitle': 'ARM DAPLink debug probe driver',
      'openocdSubtitle': 'Open On-Chip Debugger',
      'flashDefaults': 'Flash Defaults',
      'flashHistory': 'Flash History',
      'recordsStored': 'records stored',
      'clearHistoryConfirm': 'This will permanently delete all flash history records. Continue?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'historyCleared': 'History cleared',
      'application': 'Application',
      'aboutDescription': 'A cross-platform ARM chip flash tool powered by CMSIS-DAP debug probes. Supports .pack chip database and HEX/BIN firmware files.',
      'scanDirNotConnected': 'Scan directories — gRPC not yet connected',
      'importNotConnected': 'Import pack — gRPC not yet connected',
      'refreshNotConnected': 'Refresh — gRPC not yet connected',
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
      // Home page placeholders
      'devicePage': '设备页 - 即将推出',
      'packPage': 'Pack 管理 - 即将推出',
      'historyPage': '烧录历史 - 即将推出',
      'settingsPage': '设置 - 即将推出',
      'deviceConnSettings': '设备连接设置将在此处显示',
      'logReady': '[14:23:01] 就绪\n[14:23:02] 等待操作...',
      // Pack page
      'searchPacksOrChips': '搜索 Pack 或芯片...',
      'importPack': '导入 Pack',
      'refresh': '刷新',
      'noPacksInstalled': '未安装 Pack',
      'noPacksMatchSearch': '没有匹配的 Pack',
      'scanOrImportHint': '扫描目录或导入 .pack 文件以开始使用',
      'tryDifferentSearch': '请尝试其他搜索词',
      'packsLoaded': '个 Pack 已加载',
      'chipsIn': '芯片',
      'chips': '个芯片',
      // Settings page
      'appearance': '外观',
      'debugDriver': '调试驱动',
      'selectDebugDriver': '选择调试探针驱动',
      'pyocdSubtitle': 'ARM DAPLink 调试探针驱动',
      'openocdSubtitle': '开源片上调试器',
      'flashDefaults': '烧录默认值',
      'flashHistory': '烧录历史',
      'recordsStored': '条记录',
      'clearHistoryConfirm': '将永久删除所有烧录历史记录。是否继续？',
      'cancel': '取消',
      'clear': '清除',
      'historyCleared': '历史记录已清除',
      'application': '应用',
      'aboutDescription': '基于 CMSIS-DAP 调试探针的跨平台 ARM 芯片烧录工具。支持 .pack 芯片数据库和 HEX/BIN 固件文件。',
      'scanDirNotConnected': '扫描目录 — gRPC 尚未连接',
      'importNotConnected': '导入 Pack — gRPC 尚未连接',
      'refreshNotConnected': '刷新 — gRPC 尚未连接',
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
  String get searchPacksOrChips => _t('searchPacksOrChips');
  String get importPack => _t('importPack');
  String get refresh => _t('refresh');
  String get noPacksInstalled => _t('noPacksInstalled');
  String get noPacksMatchSearch => _t('noPacksMatchSearch');
  String get scanOrImportHint => _t('scanOrImportHint');
  String get tryDifferentSearch => _t('tryDifferentSearch');
  String get packsLoaded => _t('packsLoaded');
  String get chipsIn => _t('chipsIn');
  String get chips => _t('chips');
  String get appearance => _t('appearance');
  String get debugDriver => _t('debugDriver');
  String get selectDebugDriver => _t('selectDebugDriver');
  String get pyocdSubtitle => _t('pyocdSubtitle');
  String get openocdSubtitle => _t('openocdSubtitle');
  String get flashDefaults => _t('flashDefaults');
  String get flashHistory => _t('flashHistory');
  String get recordsStored => _t('recordsStored');
  String get clearHistoryConfirm => _t('clearHistoryConfirm');
  String get cancel => _t('cancel');
  String get clear => _t('clear');
  String get historyCleared => _t('historyCleared');
  String get application => _t('application');
  String get aboutDescription => _t('aboutDescription');
  String get scanDirNotConnected => _t('scanDirNotConnected');
  String get importNotConnected => _t('importNotConnected');
  String get refreshNotConnected => _t('refreshNotConnected');
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
