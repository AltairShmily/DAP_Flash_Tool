# DAP Flash Tool

基于 Flutter + Python 的嵌入式固件烧录工具，通过 DAP-Link 调试器进行芯片烧录。

## 功能特性

- 🔥 **固件烧录** — 支持 BIN、HEX、ELF 格式
- 🧹 **芯片操作** — 全片擦除、扇区擦除、复位、读取芯片 ID
- 🔌 **设备管理** — 自动探测 DAP-Link 调试器、SWD/JTAG 协议切换
- 📦 **Pack 管理** — 本地 Pack 扫描、网络 Pack 搜索下载、芯片信息查询、pyocd Pack 安装
- 🔄 **双模式复位** — 支持软件复位和硬件复位两种方式
- 🔍 **设备详情** — 获取 DAP-Link 固件版本、硬件版本、目标电压等详细信息
- 📄 **固件预览** — HEX/BIN 文件十六进制预览，支持翻页浏览
- 📜 **烧录历史** — 记录每次烧录的文件、芯片、时间、结果（最多 100 条）
- 🌙 **深色主题** — 支持深色/浅色主题切换，适应不同工作环境

## 系统架构

```
┌─────────────────────────────────────────┐
│         Flutter Desktop (Windows)        │
│  UI (Material 3)  │  Riverpod  │  gRPC  │
└──────────────────────┬──────────────────┘
                       │ gRPC (localhost:50051)
┌──────────────────────┴──────────────────┐
│           Python Backend Service         │
│  Device Svc  │  Flash Svc  │  Pack Svc  │
│         Driver Abstraction Layer         │
│      PyOCD     │     OpenOCD             │
└─────────────────────────────────────────┘
```

## 技术栈

| 层 | 技术 |
|----|------|
| 前端框架 | Flutter 3.x (Windows Desktop) |
| 状态管理 | flutter_riverpod |
| UI 组件 | Material 3 + 自定义组件 |
| 前后端通信 | gRPC (grpc + protobuf) |
| 后端语言 | Python 3.9+ |
| 烧录驱动 | pyocd + OpenOCD (subprocess) |
| 固件解析 | intelhex + pyelftools |

## 项目结构

```
DAP_Flash_Tool/
├── flutter_app/                # Flutter 桌面应用
│   └── lib/
│       ├── app.dart            # 应用入口
│       ├── main.dart           # 启动配置
│       ├── pages/              # 页面（主页、设备、Pack、历史、设置）
│       ├── providers/          # Riverpod 状态管理
│       ├── services/           # gRPC 客户端 + 后端进程管理
│       ├── theme/              # Material 3 主题定义
│       └── widgets/            # 可复用组件（卡片、进度条、日志）
├── backend/                    # Python gRPC 后端
│   ├── server.py               # gRPC 服务入口
│   ├── drivers/                # 驱动抽象层（PyOCD / OpenOCD）
│   ├── parsers/                # 固件解析器（BIN / HEX / ELF）
│   ├── pack/                   # Pack 管理（PDSC 解析）
│   ├── services/               # gRPC 服务实现
│   └── proto/                  # 生成的 Python gRPC 代码
├── proto/                      # 共享 Protobuf 定义
├── scripts/                    # 构建脚本
└── docs/compose/               # 设计文档与实现计划
```

## 快速开始

### 环境要求

- Flutter 3.x（Windows Desktop）
- Python 3.9+
- Git

### 开发环境搭建

```bash
# 克隆仓库
git clone git@github.com:AltairShmily/DAP_Flash_Tool.git
cd DAP_Flash_Tool

# Windows 一键初始化
scripts\setup_dev.bat

# 或手动操作：
# 1. Flutter 依赖
cd flutter_app && flutter pub get && cd ..

# 2. Python 虚拟环境
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cd ..

# 3. 生成 gRPC 代码
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto
cd flutter_app && protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto && cd ..
```

### 运行

```bash
# 启动后端
cd backend && python server.py

# 启动前端（另一个终端）
cd flutter_app && flutter run -d windows
```

### 构建发行版

```bash
scripts\build_windows.bat
```

## gRPC 接口

服务定义在 `proto/dap_flash.proto`，包含以下接口：

| 接口 | 类型 | 说明 |
|------|------|------|
| `ListProbes` | Unary | 列出可用调试器 |
| `ConnectProbe` | Unary | 连接调试器 |
| `DisconnectProbe` | Unary | 断开连接 |
| `GetProbeDetails` | Unary | 获取调试器详细信息（固件版本、硬件版本、目标电压） |
| `FlashFirmware` | Server Stream | 烧录固件（流式进度） |
| `EraseChip` | Server Stream | 擦除芯片（流式进度） |
| `ResetTarget` | Unary | 复位目标（支持软件/硬件复位） |
| `ReadChipId` | Unary | 读取芯片 ID |
| `ListPacks` | Unary | 列出已安装 Pack |
| `SearchPacks` | Unary | 搜索 Pack |
| `DownloadPack` | Server Stream | 下载 Pack（流式进度） |
| `InstallPack` | Unary | 安装 CMSIS Pack |
| `ListInstalledPacks` | Unary | 列出已安装的 Pack |
| `PreviewFirmware` | Unary | 预览固件文件（十六进制） |
| `GetFileInfo` | Unary | 获取固件文件信息 |
| `GetFlashHistory` | Unary | 获取烧录历史 |

## 许可证

[MIT License](LICENSE)
