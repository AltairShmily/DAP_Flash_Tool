# DAP Flash Tool - 项目设计文档

> **版本:** v1.0
> **日期:** 2026-07-30
> **状态:** 已批准

## [S1] 项目概述

构建一个基于 Flutter 的桌面 GUI 客户端，用于通过 DAP-Link 进行嵌入式固件烧录。支持 PyOCD 和 OpenOCD 两种后端驱动，通过 gRPC 进行前后端通信。

**核心功能：**
- 固件烧录（BIN、HEX、ELF）
- 芯片擦除、复位、启动
- 设备探测与连接管理
- 芯片 Pack 包管理（本地扫描 + 网络下载）
- 烧录历史记录
- 深色/浅色主题切换

**参考项目：** [USTHzhanglu/dap_download](https://github.com/USTHzhanglu/dap_download) — 基于 tkinter + pyocd 的简单烧录工具

## [S2] 系统架构

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Desktop (Windows)           │
│  ┌───────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  UI Layer │  │ State    │  │  gRPC Client     │  │
│  │  (Material│  │ Management│  │  (auto-generated)│  │
│  │   3)      │  │ (Riverpod)│  │                  │  │
│  └───────────┘  └──────────┘  └────────┬─────────┘  │
└────────────────────────────────────────┼─────────────┘
                                         │ gRPC (localhost)
┌────────────────────────────────────────┼─────────────┐
│              Python Backend Service     │             │
│  ┌─────────────────────────────────────┴──────────┐  │
│  │            gRPC Server (grpcio)                │  │
│  ├─────────────┬──────────────┬───────────────────┤  │
│  │  Flash Svc  │  Device Svc  │   Pack Svc        │  │
│  ├─────────────┴──────────────┴───────────────────┤  │
│  │           Driver Abstraction Layer             │  │
│  ├─────────────┬──────────────────────────────────┤  │
│  │   PyOCD     │   OpenOCD (subprocess)           │  │
│  │   Driver    │   Driver                         │  │
│  └─────────────┴──────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

**分层说明：**
- **Flutter 前端**：UI 渲染 + 状态管理 (Riverpod) + gRPC 客户端
- **Python 后端**：gRPC 服务 + 驱动抽象层 + 具体驱动实现
- **驱动抽象层**：统一 PyOCD 和 OpenOCD 的接口差异

## [S3] UI 设计

### 布局结构

采用侧边栏导航 + 可折叠卡片组的布局：

```
┌──────────────────────────────────────────────────────────────────┐
│  🔧 DAP Flash Tool                          [🌙/☀️] [⚙] [─][□][×] │
├──────────┬───────────────────────────────────────────────────────┤
│          │                                                       │
│  侧边栏   │   ┌─ ▼ 连接 ──────────────────────────────────────┐  │
│          │   │  🟢 CMSIS-DAP | STM32F103C8 | SWD 1MHz       │  │
│ ▸ 设备    │   │  [断开]  [刷新设备列表]                         │  │
│ ▸ 烧录    │   └───────────────────────────────────────────────┘  │
│ ▸ Pack    │                                                       │
│ ▸ 历史    │   ┌─ ▼ 烧录操作 ──────────────────────────────────┐  │
│ ▸ 设置    │   │  固件: [📁 选择文件...]     格式: hex          │  │
│          │   │  芯片: [STM32F103C8 ▾]    Pack: [已加载 ✓]     │  │
│          │   │  起始地址: [0x08000000]     [自动检测]          │  │
│          │   │  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────┐       │  │
│          │   │  │ 烧录  │ │ 擦除  │ │Reset │ │读芯片ID│       │  │
│          │   │  └──────┘ └──────┘ └──────┘ └────────┘       │  │
│          │   └───────────────────────────────────────────────┘  │
│          │                                                       │
│          │   ┌─ ▼ 输出日志 ──────────────────────────────────┐  │
│          │   │  ████████████████░░░░░░░  72%  12.3 KB/s      │  │
│          │   │  [14:23:01] Connected to target                │  │
│          │   │  [14:23:02] Erasing flash...                   │  │
│          │   │  [14:23:03] Programming 64KB...                │  │
│          │   └───────────────────────────────────────────────┘  │
├──────────┴───────────────────────────────────────────────────────┤
│  Status: Ready                                        v0.1.0    │
└──────────────────────────────────────────────────────────────────┘
```

### 页面规划

| 页面 | 功能 |
|------|------|
| **设备页** | 设备连接/断开、探测器列表、连接参数配置（SWD/JTAG、频率） |
| **烧录页** | 文件选择、芯片选择、地址配置、烧录/擦除/Reset 操作、进度日志 |
| **Pack 页** | 本地 Pack 扫描、网络 Pack 搜索下载、已安装 Pack 列表管理 |
| **历史页** | 烧录记录（文件、芯片、时间、结果）、一键重烧 |
| **设置页** | 主题切换、驱动选择（PyOCD/OpenOCD）、默认参数、语言 |

### 卡片交互

- 每个卡片可点击标题栏折叠/展开
- 折叠时只显示标题和状态摘要（如 "烧录操作 - 就绪"）
- 卡片间有 8px 间距，圆角 12px
- 连接卡片默认展开，其他按使用频率默认展开

### 主题系统

**Material 3 设计语言：**
- 动态取色（从固件图标或用户自选种子色生成配色方案）
- 深色模式：Surface `#1C1B1F`，Primary `#D0BCFF`
- 浅色模式：Surface `#FFFBFE`，Primary `#6750A4`
- 卡片使用 `surfaceContainerHighest` 色，带微弱 elevation 阴影

## [S4] 后端服务设计

### gRPC 接口定义

```protobuf
syntax = "proto3";
package dap_flash;

import "google/protobuf/empty.proto";

service DapFlashService {
  // 设备管理
  rpc ListProbes(google.protobuf.Empty) returns (ProbeList);
  rpc ConnectProbe(ConnectRequest) returns (ConnectResponse);
  rpc DisconnectProbe(google.protobuf.Empty) returns (google.protobuf.Empty);

  // 烧录操作（流式返回进度）
  rpc FlashFirmware(FlashRequest) returns (stream ProgressUpdate);
  rpc EraseChip(EraseRequest) returns (stream ProgressUpdate);
  rpc ResetTarget(google.protobuf.Empty) returns (OperationResult);
  rpc ReadChipId(google.protobuf.Empty) returns (ChipIdResult);

  // Pack 管理
  rpc ListPacks(google.protobuf.Empty) returns (PackList);
  rpc SearchPacks(SearchRequest) returns (PackSearchResult);
  rpc DownloadPack(DownloadRequest) returns (stream ProgressUpdate);

  // 历史记录
  rpc GetFlashHistory(google.protobuf.Empty) returns (FlashHistoryList);
}

// 消息定义（简化版）
message Probe {
  string id = 1;
  string name = 2;
  string vendor = 3;
  string serial_number = 4;
}

message ProbeList {
  repeated Probe probes = 1;
}

message ConnectRequest {
  string probe_id = 1;
  string target = 2;
  int32 frequency = 3;
  string protocol = 4;  // "swd" or "jtag"
}

message ConnectResponse {
  bool success = 1;
  string error_message = 2;
  string target_name = 3;
}

message FlashRequest {
  string firmware_path = 1;
  int64 start_address = 2;
  string driver = 3;  // "pyocd" or "openocd"
}

message ProgressUpdate {
  enum Phase {
    CONNECTING = 0;
    ERASING = 1;
    PROGRAMMING = 2;
    VERIFYING = 3;
    RESETTING = 4;
  }
  Phase phase = 1;
  float progress = 2;       // 0.0 - 1.0
  int64 bytes_written = 3;
  int64 total_bytes = 4;
  string message = 5;
}

message OperationResult {
  bool success = 1;
  string message = 2;
}

message ChipIdResult {
  uint32 chip_id = 1;
  string description = 2;
}

message EraseRequest {
  string mode = 1;  // "chip" or "sector"
}

message PackInfo {
  string name = 1;
  string vendor = 2;
  string version = 3;
  string path = 4;
  repeated string supported_chips = 5;
}

message PackList {
  repeated PackInfo packs = 1;
}

message SearchRequest {
  string query = 1;
}

message PackSearchResult {
  repeated PackInfo packs = 1;
}

message DownloadRequest {
  string pack_url = 1;
  string pack_name = 2;
}

message FlashRecord {
  string firmware_path = 1;
  string firmware_hash = 2;
  string chip_name = 3;
  string probe_name = 4;
  int64 timestamp = 5;
  bool success = 6;
  int64 duration_ms = 7;
  string error_message = 8;
}

message FlashHistoryList {
  repeated FlashRecord records = 1;
}
```

### 驱动抽象层

```python
from abc import ABC, abstractmethod
from typing import Callable

class BaseDriver(ABC):
    """驱动抽象基类，统一 PyOCD 和 OpenOCD 接口"""

    @abstractmethod
    def connect(self, probe_id: str, target: str, frequency: int) -> None:
        """连接到目标设备"""
        ...

    @abstractmethod
    def disconnect(self) -> None:
        """断开连接"""
        ...

    @abstractmethod
    def flash(self, file_path: str, address: int, callback: Callable[[float, str], None]) -> None:
        """烧录固件，callback(progress, message) 用于进度回调"""
        ...

    @abstractmethod
    def erase(self, mode: str) -> None:
        """擦除芯片，mode: 'chip' 或 'sector'"""
        ...

    @abstractmethod
    def reset(self) -> None:
        """复位目标"""
        ...

    @abstractmethod
    def read_chip_id(self) -> str:
        """读取芯片 ID"""
        ...
```

### OpenOCD 驱动实现思路

通过子进程启动 OpenOCD，使用 TCL 端口（默认 6666）发送命令：
- `flash write_image` — 烧录
- `flash erase_sector` / `flash erase_address` — 擦除
- `reset` — 复位
- `targets` — 读取目标状态

进度通过解析 stdout 或 GDB 端口推送。

## [S5] 数据模型

### 固件文件解析

| 格式 | 解析方式 | 提取信息 |
|------|---------|---------|
| `.bin` | 原始二进制 | 文件大小、起始地址（需用户指定或从文件名推断） |
| `.hex` | Intel HEX 格式解析 | 多段数据、起始地址（自动从记录中提取）、校验和验证 |
| `.elf` | ELF header + section 解析 | 入口地址、代码段地址和大小、符号表（可选） |

### Pack 文件解析

```
.pack (ZIP)
  └── *.pdsc (XML) → 芯片列表、Flash 算法描述、内存映射
  └── *.svd (XML)  → 外设寄存器描述（用于调试功能）
  └── FlashAlgo/   → Flash 算法二进制（.FLM 文件）
```

解析 `.pdsc` 提取：
- 芯片厂商、系列、型号列表
- Flash 地址和大小
- 烧录算法（`algo` 节点）

### Dart 数据模型

```dart
class Probe {
  final String id;
  final String name;        // e.g. "CMSIS-DAP"
  final String vendor;
  final String serialNumber;
}

class TargetChip {
  final String name;         // e.g. "STM32F103C8"
  final String vendor;
  final String packName;
  final int flashBase;       // e.g. 0x08000000
  final int flashSize;
}

class FirmwareFile {
  final String path;
  final FirmwareFormat format;  // bin/hex/elf
  final int? entryPoint;
  final List<MemorySegment> segments;
}

class FlashRecord {
  final String firmwarePath;
  final String firmwareHash;   // SHA256
  final String chipName;
  final String probeName;
  final DateTime timestamp;
  final bool success;
  final int durationMs;
  final String? errorMessage;
}
```

### 历史记录存储

使用 JSON 文件（`~/.dap_flash_tool/history.json`）存储烧录历史：
- 最多保留 100 条记录，超出自动淘汰旧记录
- 启动时加载，变更后异步写回
- 无需引入 sqflite 依赖

## [S6] 错误处理

### 后端进程管理

- Flutter 启动时自动启动 Python 后端子进程
- 通过心跳检测后端存活状态，断线自动重连
- 后端崩溃时 UI 显示"后端服务已断开"，提供重启按钮
- 关闭 Flutter 窗口时优雅关闭后端进程

### 烧录操作边界情况

| 场景 | 处理方式 |
|------|---------|
| 设备未连接 | 按钮置灰，提示"请先连接设备" |
| 未选择固件 | 按钮置灰，提示"请选择固件文件" |
| 未加载 Pack | 使用 PyOCD 自动检测 target，失败则提示选择 |
| 烧录中途断开 | 捕获异常，日志显示错误，提示"烧录失败：设备断开" |
| 文件格式错误 | 解析阶段拦截，显示具体错误（如 HEX 校验失败） |
| 地址越界 | 烧录前校验地址范围，超出 Flash 区域则拒绝并提示 |
| 多次点击烧录 | 操作进行中禁用所有操作按钮，防止重复执行 |

### Pack 下载边界情况

- 网络不可用时提示并隐藏在线搜索
- 下载中断支持断点续传（HTTP Range）
- Pack 文件损坏（ZIP 解压失败）时提示重新下载

## [S7] 项目结构

```
dap_flash_tool/
├── flutter_app/                    # Flutter 桌面应用
│   ├── lib/
│   │   ├── main.dart               # 应用入口
│   │   ├── app.dart                # MaterialApp 配置、主题、路由
│   │   ├── proto/                  # gRPC 生成的 Dart 代码
│   │   │   └── dap_flash.pb.dart
│   │   ├── services/               # gRPC 客户端封装
│   │   │   ├── grpc_client.dart    # 连接管理、重试逻辑
│   │   │   ├── flash_service.dart
│   │   │   ├── device_service.dart
│   │   │   └── pack_service.dart
│   │   ├── providers/              # Riverpod 状态管理
│   │   │   ├── device_provider.dart
│   │   │   ├── flash_provider.dart
│   │   │   ├── pack_provider.dart
│   │   │   ├── history_provider.dart
│   │   │   └── theme_provider.dart
│   │   ├── models/                 # Dart 数据模型
│   │   │   ├── probe.dart
│   │   │   ├── chip.dart
│   │   │   ├── firmware.dart
│   │   │   └── flash_record.dart
│   │   ├── pages/                  # 页面
│   │   │   ├── home_page.dart      # 主页面（卡片布局）
│   │   │   ├── device_page.dart    # 设备管理
│   │   │   ├── pack_page.dart      # Pack 管理
│   │   │   ├── history_page.dart   # 烧录历史
│   │   │   └── settings_page.dart  # 设置
│   │   ├── widgets/                # 可复用组件
│   │   │   ├── collapsible_card.dart
│   │   │   ├── progress_bar.dart
│   │   │   ├── log_console.dart
│   │   │   ├── file_picker.dart
│   │   │   └── chip_selector.dart
│   │   └── theme/                  # 主题定义
│   │       ├── app_theme.dart
│   │       └── colors.dart
│   ├── windows/                    # Windows 平台配置
│   └── pubspec.yaml
│
├── backend/                        # Python 后端服务
│   ├── server.py                   # gRPC 服务入口
│   ├── requirements.txt            # pyocd, grpcio, protobuf, etc.
│   ├── proto/
│   │   └── dap_flash.proto         # 接口定义
│   ├── services/
│   │   ├── flash_service.py
│   │   ├── device_service.py
│   │   └── pack_service.py
│   ├── drivers/
│   │   ├── base.py
│   │   ├── pyocd_driver.py
│   │   └── openocd_driver.py
│   ├── parsers/
│   │   ├── hex_parser.py
│   │   └── elf_parser.py
│   └── pack/
│       ├── pack_manager.py
│       └── pack_parser.py
│
├── proto/                          # 共享 proto 定义
│   └── dap_flash.proto
│
└── scripts/
    ├── build_windows.bat           # 打包脚本
    └── setup_dev.sh                # 开发环境初始化
```

## [S8] 技术栈

| 层 | 技术 |
|----|------|
| 前端框架 | Flutter 3.x (Windows Desktop) |
| 状态管理 | flutter_riverpod |
| UI 组件 | Material 3 + 自定义组件 |
| 前后端通信 | gRPC (grpc + grpc-web) |
| 本地存储 | JSON 文件 (历史记录) |
| 后端语言 | Python 3.9+ |
| gRPC 框架 | grpcio + grpcio-tools |
| 烧录驱动 | pyocd + OpenOCD (subprocess) |
| HEX 解析 | intelhex (Python 库) |
| ELF 解析 | pyelftools (Python 库) |
| 打包分发 | Flutter 打包 + PyInstaller 打包 Python |

## [S9] 部署方案

- 使用 PyInstaller 将 Python 后端打包为单个可执行文件
- Flutter 打包为 Windows 安装包
- 安装包内嵌 Python 后端可执行文件
- 启动时 Flutter 自动拉起后端进程
