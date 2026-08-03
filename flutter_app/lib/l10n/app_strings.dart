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
      'devicePage': 'Device Management',
      'packPage': 'Pack Management - Coming Soon',
      'historyPage': 'Flash History',
      'settingsPage': 'Settings - Coming Soon',
      'deviceConnSettings': 'Connection parameters',
      'logReady': 'Ready — waiting for operation...',
      // Device page
      'probeList': 'Probe List',
      'noProbesFound': 'No probes found',
      'connectProbe': 'Connect',
      'disconnectProbe': 'Disconnect',
      'connectionParams': 'Connection Parameters',
      'protocol': 'Protocol',
      'frequency': 'Frequency',
      'connectedDeviceInfo': 'Connected Device',
      'scanning': 'Scanning...',
      'probeId': 'Probe ID',
      'probeVendor': 'Vendor',
      'probeSerial': 'Serial',
      'connectFirst': 'Please connect a device first',
      'connectionFailed': 'Connection failed',
      'connectedSuccessfully': 'Connected successfully',
      'disconnected': 'Disconnected',
      'probeScanned': 'probes found',
      'noProbeSelected': 'No probe selected',
      // History page
      'noHistory': 'No flash history',
      'noHistoryHint': 'Flash records will appear here after firmware operations',
      'reflash': 'Re-flash',
      'flashSuccess': 'Success',
      'flashFailed': 'Failed',
      'clearHistoryBtn': 'Clear All',
      'duration': 'Duration',
      'chipName': 'Chip',
      'firmwareFile': 'Firmware',
      // Log / status
      'logFlashing': 'Flashing firmware...',
      'logErasing': 'Erasing chip...',
      'logReset': 'Target reset',
      'logChipId': 'Chip ID',
      'logConnecting': 'Connecting...',
      'logProgramming': 'Programming...',
      'logVerifying': 'Verifying...',
      'logComplete': 'Operation complete',
      'logError': 'Error',
      'statusConnected': 'Status: Connected',
      'statusFlashing': 'Status: Flashing',
      'statusErasing': 'Status: Erasing',
      'selectChipFirst': 'Please select a target chip',
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
      'advanced': 'Advanced',
      'targetPower': 'Target Power',
      'targetPowerOn': 'Power On',
      'targetPowerOff': 'Power Off',
      'searchHistory': 'Search history...',
      'undo': 'Undo',
      'recordDeleted': 'Record deleted',
      'speed': 'Speed',
      'bytesWritten': 'Bytes written',
      'chipErase': 'Chip Erase',
      'sectorErase': 'Sector Erase',
      'startFlash': 'Start Flash',
      'eraseChip': 'Erase Chip',
      'notConnected': 'Not connected',
      'flashProgress': 'Flash Progress',
      'noResults': 'No results',
      'flashResult': 'Flash Result',
      'operationSuccess': 'Operation Successful',
      'operationFailed': 'Operation Failed',
      'close': 'Close',
      'address': 'Address',
      'clearLog': 'Clear Log',
      'connectionStatus': 'Connection Status',
      'eraseMode': 'Erase Mode',
      'firmwarePathHint': 'Select or enter firmware path',
      'inProgress': 'In Progress...',
      'loadPack': 'Load Pack',
      'operation': 'Operation',
      'speedTest': 'Speed Test',
      'flashPage': 'Flash',
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
      'devicePage': '设备管理',
      'packPage': 'Pack 管理 - 即将推出',
      'historyPage': '烧录历史',
      'settingsPage': '设置 - 即将推出',
      'deviceConnSettings': '连接参数',
      'logReady': '就绪 — 等待操作...',
      // Device page
      'probeList': '探针列表',
      'noProbesFound': '未找到探针',
      'connectProbe': '连接',
      'disconnectProbe': '断开',
      'connectionParams': '连接参数',
      'protocol': '协议',
      'frequency': '频率',
      'connectedDeviceInfo': '已连接设备',
      'scanning': '扫描中...',
      'probeId': '探针 ID',
      'probeVendor': '厂商',
      'probeSerial': '序列号',
      'connectFirst': '请先连接设备',
      'connectionFailed': '连接失败',
      'connectedSuccessfully': '连接成功',
      'disconnected': '已断开',
      'probeScanned': '个探针已发现',
      'noProbeSelected': '未选择探针',
      // History page
      'noHistory': '暂无烧录历史',
      'noHistoryHint': '烧录记录将在固件操作后显示在此处',
      'reflash': '重新烧录',
      'flashSuccess': '成功',
      'flashFailed': '失败',
      'clearHistoryBtn': '清除全部',
      'duration': '耗时',
      'chipName': '芯片',
      'firmwareFile': '固件',
      // Log / status
      'logFlashing': '烧录固件中...',
      'logErasing': '擦除芯片中...',
      'logReset': '目标已复位',
      'logChipId': '芯片 ID',
      'logConnecting': '连接中...',
      'logProgramming': '编程中...',
      'logVerifying': '验证中...',
      'logComplete': '操作完成',
      'logError': '错误',
      'statusConnected': '状态: 已连接',
      'statusFlashing': '状态: 烧录中',
      'statusErasing': '状态: 擦除中',
      'selectChipFirst': '请选择目标芯片',
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
      'advanced': '高级',
      'targetPower': '目标电源',
      'targetPowerOn': '供电',
      'targetPowerOff': '断电',
      'searchHistory': '搜索历史...',
      'undo': '撤销',
      'recordDeleted': '记录已删除',
      'speed': '速度',
      'bytesWritten': '已写入字节',
      'chipErase': '整片擦除',
      'sectorErase': '扇区擦除',
      'startFlash': '开始烧录',
      'eraseChip': '擦除芯片',
      'notConnected': '未连接',
      'flashProgress': '烧录进度',
      'noResults': '无结果',
      'flashResult': '烧录结果',
      'operationSuccess': '操作成功',
      'operationFailed': '操作失败',
      'close': '关闭',
      'address': '地址',
      'clearLog': '清除日志',
      'connectionStatus': '连接状态',
      'eraseMode': '擦除模式',
      'firmwarePathHint': '选择或输入固件路径',
      'inProgress': '进行中...',
      'loadPack': '加载 Pack',
      'operation': '操作',
      'speedTest': '速度测试',
      'flashPage': '烧录',
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
  String get advanced => _t('advanced');
  String get targetPower => _t('targetPower');
  String get targetPowerOn => _t('targetPowerOn');
  String get targetPowerOff => _t('targetPowerOff');
  String get searchHistory => _t('searchHistory');
  String get undo => _t('undo');
  String get recordDeleted => _t('recordDeleted');
  String get speed => _t('speed');
  String get bytesWritten => _t('bytesWritten');
  String get chipErase => _t('chipErase');
  String get sectorErase => _t('sectorErase');
  String get startFlash => _t('startFlash');
  String get eraseChip => _t('eraseChip');
  String get notConnected => _t('notConnected');
  String get flashProgress => _t('flashProgress');
  String get noResults => _t('noResults');
  String get flashResult => _t('flashResult');
  String get operationSuccess => _t('operationSuccess');
  String get operationFailed => _t('operationFailed');
  String get close => _t('close');
  String get clearLog => _t('clearLog');
  String get connectionStatus => _t('connectionStatus');
  String get operation => _t('operation');
  String get firmwarePathHint => _t('firmwarePathHint');
  String get loadPack => _t('loadPack');
  String get address => _t('address');
  String get eraseMode => _t('eraseMode');
  String get inProgress => _t('inProgress');
  String get speedTest => _t('speedTest');
  String get flashPage => _t('flashPage');
  String get probeList => _t('probeList');
  String get noProbesFound => _t('noProbesFound');
  String get connectProbe => _t('connectProbe');
  String get disconnectProbe => _t('disconnectProbe');
  String get connectionParams => _t('connectionParams');
  String get protocol => _t('protocol');
  String get frequency => _t('frequency');
  String get connectedDeviceInfo => _t('connectedDeviceInfo');
  String get scanning => _t('scanning');
  String get probeId => _t('probeId');
  String get probeVendor => _t('probeVendor');
  String get probeSerial => _t('probeSerial');
  String get connectFirst => _t('connectFirst');
  String get connectionFailed => _t('connectionFailed');
  String get connectedSuccessfully => _t('connectedSuccessfully');
  String get disconnected => _t('disconnected');
  String get probeScanned => _t('probeScanned');
  String get noProbeSelected => _t('noProbeSelected');
  String get noHistory => _t('noHistory');
  String get noHistoryHint => _t('noHistoryHint');
  String get reflash => _t('reflash');
  String get flashSuccess => _t('flashSuccess');
  String get flashFailed => _t('flashFailed');
  String get clearHistoryBtn => _t('clearHistoryBtn');
  String get duration => _t('duration');
  String get chipName => _t('chipName');
  String get firmwareFile => _t('firmwareFile');
  String get logFlashing => _t('logFlashing');
  String get logErasing => _t('logErasing');
  String get logReset => _t('logReset');
  String get logChipId => _t('logChipId');
  String get logConnecting => _t('logConnecting');
  String get logProgramming => _t('logProgramming');
  String get logVerifying => _t('logVerifying');
  String get logComplete => _t('logComplete');
  String get logError => _t('logError');
  String get statusConnected => _t('statusConnected');
  String get statusFlashing => _t('statusFlashing');
  String get statusErasing => _t('statusErasing');
  String get selectChipFirst => _t('selectChipFirst');
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
