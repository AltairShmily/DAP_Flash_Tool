# 更新日志

本项目所有重要变更均记录于此。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [0.1.0] - 2026-07-30

### 新增

#### Python 后端
- gRPC 服务层，监听 `localhost:50051`，提供 11 个 RPC 接口
- 驱动抽象层，统一 PyOCD 和 OpenOCD 接口差异
- PyOCD 驱动实现（Python 原生调用）
- OpenOCD 驱动实现（子进程 + TCL 端口通信）
- 固件文件解析器：BIN（原始二进制）、HEX（Intel HEX）、ELF（可执行文件格式）
- Pack 管理模块：`.pack` / `.pdsc` 解析、本地目录扫描、芯片搜索
- gRPC 服务实现：设备管理、烧录操作（流式进度）、Pack 管理、历史记录

#### Flutter 前端
- Material 3 设计主题，支持深色/浅色切换
- 可折叠卡片组件、进度条组件、日志控制台组件
- Riverpod 状态管理：Theme、Device、Flash、History、Pack 五个 Provider
- gRPC 客户端封装：GrpcClient 单例、DeviceService、FlashService
- 主页面布局：侧边栏导航 + 标题栏 + 卡片内容区 + 状态栏
- 烧录页：连接卡片、烧录操作卡片、输出日志卡片
- 后端进程管理器：自动启动 Python 服务、健康检查

#### 工程化
- Protobuf 接口定义（11 个 RPC、15 个消息类型）
- Python gRPC 代码生成
- 开发环境初始化脚本（`scripts/setup_dev.bat`）
- Windows 构建打包脚本（`scripts/build_windows.bat`）
- 设计文档与实现计划

### 决策记录

1. **架构：Flutter + Python gRPC**
   - **决策：** Flutter 桌面前端通过 gRPC（localhost）与 Python 后端通信
   - **理由：** gRPC 提供类型安全接口、双向流式传输进度更新、前后端职责清晰分离
   - **备选方案：** REST API + SSE（更简单但无类型安全）、Dart FFI 直调（性能最佳但需重写 PyOCD）

2. **双驱动支持：PyOCD + OpenOCD**
   - **决策：** 通过统一抽象层同时支持 PyOCD 和 OpenOCD
   - **理由：** 用户有不同的硬件和偏好需求；PyOCD 集成简单，OpenOCD 硬件支持更广

3. **UI 框架：Material 3 + 可折叠卡片**
   - **决策：** 使用 Material 3 设计语言，卡片可折叠
   - **理由：** 现代化、可访问性好；折叠卡片让用户聚焦于当前操作区域

4. **主题系统：深色/浅色切换**
   - **决策：** 支持用户手动切换深色和浅色主题
   - **理由：** 嵌入式开发者常在明亮办公室和暗室实验室之间切换

5. **历史存储：JSON 文件**
   - **决策：** 使用 JSON 文件存储烧录历史（最多 100 条），而非 SQLite
   - **理由：** 实现简单、无额外依赖、数据量足够

6. **Pack 管理：本地扫描 + 网络下载**
   - **决策：** 支持本地 Pack 目录扫描和网络 Pack 下载
   - **理由：** 用户可能已有本地 Pack 文件，也可能需要从厂商网站下载

7. **后端进程管理：自动启动 + 健康检查**
   - **决策：** Flutter 启动时自动拉起 Python 后端，定期健康检查
   - **理由：** 提供无缝用户体验，用户无需手动启动后端

### 测试结果

- `test_import.py` — Proto 导入验证 ✅
- `test_drivers.py` — BaseDriver 抽象检查 ✅、OpenOCD 初始化 ✅（PyOCD 跳过，未安装）
- `test_parsers.py` — BIN ✅、HEX ✅、ELF ✅
- `test_pack.py` — PackManager ✅、PackParser ✅
- `server.py` 启动 — gRPC 服务正常监听 ✅

### 已知问题

- Dart gRPC 代码需在有 Dart SDK 的环境执行生成
- PyOCD 驱动需在目标机器安装 `pyocd` 包才能实际烧录
- Flutter 桌面构建需 Windows 环境

---

## 未来条目模板

```markdown
## [X.Y.Z] - YYYY-MM-DD

### 新增
- 新功能

### 变更
- 已有功能的变更

### 废弃
- 将在未来版本移除的功能

### 移除
- 已移除的功能

### 修复
- Bug 修复

### 安全
- 安全相关变更

### 决策
- 关键架构或设计决策及其理由
```
