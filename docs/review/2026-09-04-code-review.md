# DAP Flash Tool — 代码审查报告（第二轮）

> 日期：2026-09-04
> 审查范围：全仓库（backend、flutter_app、proto、docs、scripts、CI）
> 方法：逐文件阅读 + 基于 venv（pyocd 0.45.1 / intelhex / grpcio）的运行时实证验证
> 环境：Flutter 3.47.0 analyze ✅ 0 issues；flutter test ✅ 2/2；backend pytest ✅ 21/21
> 前次审查：docs/review/2026-08-19-code-review.md、2026-08-19-fix-plan.md

---

## 0. 总体结论

工程骨架完整、静态检查全绿，但**绿测具有欺骗性**：核心的"烧录"与"Pack 解析"链路存在
运行时必炸的 P0 缺陷，且现有测试用自造数据/错误断言掩盖了这些问题。
README 宣传的多项功能（在线 Pack 下载、固件预览、设备详情、双驱动）实际端到端不可达。

**优先级判断：先修 P0-1 ~ P0-4（烧录主链路），再补 P1 功能闭环，最后做优化与增强。**

---

## 1. 上轮（2026-08-19）问题修复状态核对

| 上轮编号 | 问题 | 当前状态 |
|---|---|---|
| P0#1/#2 | pbgrpc.dart 类型不一致 | ✅ 已修复（ListPacksRequest/ResetRequest 正确） |
| P0#3 | file_service.py 缺 import grpc | ✅ 已修复 |
| P1#1 | pack 下载传本地路径 | ⚠️ 半修复：proto 增加 download_url、前端按其门控，但后端恒置空 → 下载功能名存实亡 |
| P1#2 | pack_service 耦合 driver | ✅ 已修复（改走 PackManager） |
| P1#3 | 固件预览页占位 | ⚠️ 半修复：已接入 gRPC，但页面无导航入口 + HEX offset 语义错误（见 Bug#6） |
| N-1~N-5 | 文案/测试/API 迁移/语言切换 | ✅ 全部修复 |
| Phase4.1 | 历史持久化 | ⚠️ 后端已持久化，但前端从不调用 GetFlashHistory，形成双轨历史（见 Bug#16） |

---

## 2. Bug 清单

> 每条均给出证据位置；标注【实证】者已在 venv 中运行复现。

### P0 — 核心功能不可用

**Bug#1 PyOCD 烧录必然崩溃：进度回调签名不匹配**【实证】
- 位置：`backend/drivers/pyocd_driver.py:64-69`
- pyocd 的 ProgressCallback 签名为 `Callable[[float], None]`（单参数百分比，
  venv `pyocd/flash/loader.py:37,370`），驱动却定义 `progress_handler(progress, total)` 双参数。
- 实证：`progress_handler(0.5)` → `TypeError: missing 1 required positional argument: 'total'`。
- 影响：**任何一次真实烧录在第一个进度回调即抛异常**，烧录功能整体不可用。
- 修复：回调改单参数 `def progress_handler(pct: float)`，直接 `callback(pct, f"Programming {pct*100:.1f}%")`。

**Bug#2 真实 CMSIS-Pack 解析结果全空**【实证】
- 位置：`backend/pack/pack_parser.py:20-58`
- 真实 PDSC 中 name/vendor 是 `<package>` 的**子元素**、版本在 `<releases><release version>`、
  设备名属性是 `Dname`（family 是 `Dfamily`），而解析器按根元素属性和 `name` 属性读取。
- 实证：用 Keil 风格 PDSC（schemaVersion 1.7.28）解析 → `name='Unknown' vendor='Unknown' version='0.0.0' chips=0`。
- 连锁影响：ListPacks/SearchPacks 芯片列表恒空 → 前端芯片选择、搜索全部失效。
- `test_pack.py` 的 SAMPLE_PDSC 是**自造的非标准格式**，导致测试假阳性通过。
- 修复：按 CMSIS-Pack schema 重写解析（子元素 name/vendor、release[0]/@version、Dname/Dfamily/Dvendor、
  memory 按 `access`/`id`/`name` 模糊匹配 + `<algorithm start/size>` 兜底），并用真实 Keil/ST pack 建回归夹具。

**Bug#3 烧录失败被前端显示为"成功"**
- 位置：`backend/services/flash_service.py:94-97` + `flutter_app/lib/providers/flash_provider.dart:158` + `home_page.dart:206-227`
- 后端把异常当作普通 ProgressUpdate（message="Error: ..."）yield 后流正常结束；
  前端流结束即无条件 `complete('Flash completed successfully')`，覆盖了错误消息；
  home_page 用 `statusMessage.startsWith('Error')` 判断成败 → 恒判成功。
- 影响：**失败烧录弹"成功"对话框、历史记为成功**，用户可能误以为固件已写入。
- 修复：ProgressUpdate 增加 `bool success` / `string error` 字段（或后端直接抛异常走 gRPC status），
  前端按显式状态判断，禁止字符串前缀推断。

**Bug#4 SWD 频率单位错误：实际时钟比设定低 1000 倍**【实证】
- 位置：`flutter_app/lib/pages/device_page.dart:273-277`、`device_provider.dart:23`（默认 4000）
- UI 下拉值 1000/2000/4000/8000 标注为 "1/2/4/8 MHz"（kHz 语义），原样发给后端；
  pyocd `frequency` 选项单位为 **Hz**（venv `pyocd/core/options.py:85-86`："SWD/JTAG frequency in Hertz"，默认 1000000）。
- 影响：选 "4 MHz" 实际以 4 kHz 通信，烧录极慢或直接失败。
- 修复：前端统一以 Hz 传输（value: 1000000 等），或在后端做 kHz→Hz 换算；默认值改 1000000。

### P1 — 重大功能缺陷

**Bug#5 烧录进度非实时（伪流式）**
- 位置：`backend/services/flash_service.py:76-85`
- 进度回调先收集进 list，`driver.flash()` **返回后**才逐条 yield → UI 在整个烧录期间停留在 0%，
  结束后一次性刷出全部进度。设计文档 S4 明确要求流式进度。
- 修复：`queue.Queue` 桥接——回调线程 put，生成器循环 `get(timeout=...)` 实时 yield，哨兵值结束。

**Bug#6 固件预览页不可达 + HEX 预览分页语义错误**【实证】
- 位置：`flutter_app/lib/pages/firmware_preview_page.dart`（全文件无导航引用）、
  `backend/parsers/hex_preview.py:19-22`、`firmware_preview_page.dart:98`
- 实证：HEX 数据在 0x08000000，UI 首页发 offset=0 → 后端 `tobinarray(start=0)` 返回
  `FF FF FF ...` 纯填充；`total_size=4` → 翻页条件 `offset+256 < 4` 恒假，"下一页"永不启用。
- 另外 `.elf` 被 `get_file_info` 报成 `format='bin'`。【实证】
- 修复：为页面加入口（烧录卡片"预览"按钮）；HEX 预览以 base_address 为起点做**相对偏移**分页
  （`start = base_address + offset`），或统一先把 HEX 转成线性 bin 再预览；补 ELF 分支。

**Bug#7 Pack 在线搜索/下载端到端缺失 + DownloadPack 安全隐患**
- 位置：`backend/services/pack_service.py:36-68`、`pack_page.dart:362`
- SearchPacks 只搜**本地已解析** pack 的芯片且 `download_url=''` 恒空 → 下载按钮永不出现，
  README 宣传的"网络 Pack 搜索下载"不可用。
- DownloadPack 本身：`urllib.request.urlretrieve(request.pack_url, ...)` 无 scheme 校验
  （`file://` 可读本地文件）、`dest_path = os.path.join(pack_dir, request.pack_name)` 未净化
  （`../` 路径穿越可写任意路径）、无下载进度（0%→100% 跳变）、无断点续传、无完整性校验——
  设计文档 S6 明确要求后三项。
- 修复：实现 Keil pidx 在线索引搜索并填充 download_url；下载校验 http/https、
  `os.path.basename(pack_name)`、流式下载上报进度、HTTP Range 续传、SHA256 校验。

**Bug#8 Import Pack 按钮仍是占位**
- 位置：`pack_page.dart:99-107`（只弹 SnackBar）；dart `PackService` 无 installPack 封装；
  后端 `InstallPack` RPC 已实现却无人调用。
- 修复：文件选择器选 `.pack` → 调 InstallPack → 刷新列表。

**Bug#9 "Scan Directory" 名不副实**
- 位置：`pack_page.dart:91`（仅重调 ListPacks）；`PackManager.scan_directory` 未暴露为 RPC。
- 影响：用户手动把 .pack 放入 `~/.dap_flash_tool/packs` 永远不出现在列表（index.json 只在
  DownloadPack/install 时更新）。
- 修复：新增 ScanPacks RPC（可带目录参数），按钮走目录选择器 + 扫描。

**Bug#10 OpenOCD 驱动不可达且自身不可用**
- 位置：`backend/services/device_service.py:55`（ConnectProbe 硬编码 "pyocd"）、
  `settings_page.dart` 驱动选择无人消费、`openocd_driver.py` 全文
- openocd_driver 问题集：`_send_tcl` 单次 `recv(4096)` 无结束符/分片处理；
  erase 硬编码 STM32 地址 `0x08000000 0x20000`；`flash erase_sector 0 0 last` 参数序错误
  （正确为 `flash erase_sector <bank> <first> <last>`）；connect 靠 `sleep(1)` 猜测启动成功；
  stdout/stderr PIPE 从不读取（缓冲区满可致子进程假死）；list_probes 恒空 → UI 永远扫不到探针。
- 修复：短期在设置页禁用 OpenOCD 选项并注明"未完成"；中期用 telnet 会话式交互 + 响应终结符
  协议重写，target cfg/地址从 Pack 芯片信息推导。

**Bug#11 后端进程生命周期缺陷**
- 位置：`flutter_app/lib/services/backend_manager.dart:38-45,103-143,146-154`
- ① 应用退出从不调用 `stop()` → Python 进程孤儿化（设计 S6 要求优雅关闭）；
  ② `_probeGrpc` 仅 TCP 连通即认定"后端已在线"——50051 被任意其他程序占用时，
  RPC 全部打向错误服务；③ dev 模式 `'../backend/server.py'` 相对 cwd，
  从非 flutter_app 目录启动即找不到后端；④ 端口硬编码，冲突时无法降级。
- 修复：监听 `appWindow` 关闭事件调用 stop()；启动握手改为"子进程 stdout 打印就绪标记/端口"；
  用绝对路径（基于 Platform.resolvedExecutable 推导仓库根）；支持动态端口。

**Bug#12 gRPC 绑定所有网卡 + 任意文件读取面**
- 位置：`backend/server.py:43`（`add_insecure_port("[::]:50051")`）
- 设计 S2 明确 "gRPC runs on localhost only"。当前局域网内任何主机可调用
  PreviewFirmware 读任意路径 hex dump、DownloadPack 配合 Bug#7 写任意路径。
- 修复：绑定 `127.0.0.1:50051`；PreviewFirmware 限制扩展名（bin/hex/elf）并拒绝符号链接逃逸。

**Bug#13 擦除操作被记成"烧录历史"并弹烧录结果对话框**
- 位置：`home_page.dart:206-227`
- `ref.listen` 只判断 `isOperating true→false`，未区分 flash/erase → 擦除也 addRecord +
  弹 "Flash Result" 对话框。
- 修复：FlashState 增加 operationType 字段，listen 中区分。

**Bug#14 扇区擦除静默无效**
- 位置：`backend/drivers/pyocd_driver.py:79-80` + venv `pyocd/flash/eraser.py:80`
  （`elif mode == SECTOR and addresses:` → addresses=None 时什么都不做）；
  proto `EraseRequest` 只有 mode 无地址范围，扇区擦除在协议层就无法表达。
- 修复：EraseRequest 增加 start/length 字段；驱动传 addresses；无地址时 UI 禁用"扇区擦除"。

### P2 — 中等

**Bug#15 device_provider.copyWith 无法清空可空字段**
- `device_provider.dart:30-52`：`setDisconnected()` 传 null 不清除 probeName/targetName/
  selectedProbeId；`setConnected(errorMessage: null)` 不清除旧错误 → 状态残留。
  （同文件 pack_provider 已用 clearXxx 标志位方案，可照搬。）

**Bug#16 历史记录双轨且字段缺失**
- 前端 `history.json`（hash=''、durationMs=0，`home_page.dart:213-224`）与后端
  `flash_history.json`（chip_name=''、无 hash，`flash_service.py:51-59`）各存一份、互相不调用；
  设计要求的 firmware SHA256 无人计算；GetFlashHistory RPC 前端从未调用。
- 修复：以后端为唯一数据源，烧录时由后端计算 hash/chip/duration，前端历史页改调 GetFlashHistory。

**Bug#17 PyOCD connect 可能无限阻塞 gRPC 线程**
- `pyocd_driver.py:45-49`：`session_with_chosen_probe` 默认 `blocking=True`——
  探针未找到时挂起等待插拔；多探针匹配时打印**命令行选择菜单**等 stdin（服务端无 stdin）。
  前端 connect 无超时 → UI 永久转圈。
- 修复：传 `blocking=False`，None 时抛"未找到探针"；或 `return_first=False + unique_id` 精确匹配失败即报错。

**Bug#18 connect 的 protocol 参数被忽略**
- `pyocd_driver.py:44-50`：未传 `dap_protocol`/`connect_mode` 选项，UI 的 SWD/JTAG 切换无效。

**Bug#19 BIN 烧录起始地址被忽略**
- `pyocd_driver.py:69`：`FileProgrammer.program(file_path)` 未传 `base_address=address`
  （pyocd 支持该 kwarg，见 file_programmer.py add_file 文档）→ UI"起始地址"对 BIN 无效，
  pyocd 用 boot memory 基址。

**Bug#20 bytes_written/total_bytes/speed 全链路未实现**
- 后端从不填 ProgressUpdate 的字节字段；前端 bytesWritten/totalBytes 恒 0（`home_page.dart:587` 条件永假）、
  speedText 恒 null → "Speed Test" 卡片（home_page.dart:661-709）纯装饰。
- 修复：驱动回调带字节数 → 服务层填充 → 前端算速率/ETA。

**Bug#21 进度条 5 段相位显示恒停在"连接"**
- `progress_bar.dart:26,98` 支持 currentPhase，`home_page.dart:581-585` 从不传 → 恒 0；
  相位标签硬编码中文（progress_bar.dart:15-19），绕过 AppStrings。

**Bug#22 device_page 高级区可崩溃（StateError）**
- `device_page.dart:529-534`：isConnected 且 probes 为空时（连接后拔探针再点刷新）
  `firstWhere(orElse: () => probes.first)` 对空列表抛 StateError → 红屏。

**Bug#23 后端共享状态无锁**
- `flash_service.py` `_flash_history`、`pack_manager.py` `_packs` 被 10-worker 线程池并发读写。
- 修复：threading.Lock 包住读改写。

**Bug#24 parse_hex 的 entry_point 可能是 dict**
- `hex_parser.py:33`：intelhex `start_addr` 在存在 type 03/05 记录时返回 dict（如 {'EIP': ...}），
  违反 `ParsedFirmware.entry_point: int | None` 契约。应取 `start_addr.get('EIP')` 或 None。

**Bug#25 CI 与脚本缺陷**
- `ci.yml:57`：`timeout 5 python server.py || true` 恒真，服务器启动验证形同虚设；
- `setup_dev.bat`：cmd 中 `mkdir -p` 会创建名为 `-p` 的垃圾目录；引用不存在的 `scripts\run_dev.bat`；
- CI 每次重新生成 proto 但不校验与已提交生成物一致（漂移不会被发现；当前 pb2_grpc.py 为绝对导入，
  与 CI sed 后的相对导入版本已不一致）。
- 修复：生成后 `git diff --exit-code`；启动验证改为 import + 端口探测；bat 修正。

**Bug#26 文件选择器允许 uf2 但后端不支持**
- `home_page.dart:65`：allowedExtensions 含 'uf2'，解析/烧录链路无 UF2 处理 → 选中后静默失败。

**Bug#27 地址输入十进制回退错误**
- `home_page.dart:79-82,101-105`：无 0x 前缀的 "08000000" 按十进制解析为 8,000,000（=0x7A1200）。
  嵌入式场景应默认按 16 进制解析并校验 4 字节对齐/范围。

### P3 — 轻微

- **#28 i18n 混乱**：'软件复位/硬件复位'（device_page.dart:458,479）、'下载'（pack_page.dart:366）、
  firmware_preview_page 全中文硬编码、progress_bar 相位中文，与 AppStrings en/zh 双轨并存；
  en 词条含 'Coming Soon' 占位残留（app_strings.dart:55-58）。
- **#29 google_fonts 运行时联网**（app_theme.dart:35-36）：离线环境（实验室常态）字体静默回退，
  建议字体打包进 assets。
- **#30 死代码/死依赖**：`widgets/sidebar.dart` AppSidebar 无人使用（home 用 NavigationRail）；
  pubspec 的 json_annotation/json_serializable/build_runner 未使用；
  `backend/test_import.py` 与 `test_imports.py`、`_check.py` 职责重复。
- **#31 版本号不一致**：pubspec `1.0.0+1` vs UI/README `v0.1.0`。
- **#32 日志无上限且不自动滚动**：log_provider 列表无限增长；LogConsole 无 scroll-to-bottom。
- **#33 read_chip_id 硬编码 STM32 地址 0xE0042000**：非 STM32 目标返回无意义值；
  应从 Pack/target 信息推导或读 CPUID(0xE000ED00) 作通用兜底。
- **#34 测试假阳性**：test_drivers.py 的 install_pack/list_installed_packs 测试因
  `pyocd.pack` 导入失败（ModuleNotFoundError，实证）而"通过"，断言的是坏实现；
  建议改为 mock cmsis_pack_manager 真实 API（venv 已装 cmsis_pack_manager 0.6.0）。
- **#35 Target Power 开关纯装饰**（device_page.dart:544-561）：_targetPower 不控制任何后端行为。
- **#36 固件选择按钮 tooltip 误用 `strings.loadPack`**（home_page.dart:546）。
- **#37 PyInstaller spec 未验证**：datas 整包塞 pyocd 目录（体积大）、excludes 含 pytest 但
  pyocd 依赖树（pylink/capstone 等）未做 smoke 运行验证。

---

## 3. 优化方案（按投入产出排序）

### 3.1 烧录主链路重构（对应 Bug#1/3/5/20，收益最大）
1. 驱动回调统一为 `callback(pct: float, bytes_done: int, bytes_total: int, msg: str)`；
2. flash_service 用 `queue.Queue` 实现真流式：工作线程执行 driver.flash，
   生成器 `q.get(timeout=0.5)` 循环 yield，含速率计算（bytes/s、ETA）；
3. ProgressUpdate 增加 `success`/`error` 字段，错误走显式状态而非消息字符串；
4. 前端 flash_provider 按 phase 更新 currentPhase + bytesWritten/totalBytes + speedText，
   进度条/Speed Test 卡片即活。

### 3.2 Pack 子系统重写（对应 Bug#2/7/8/9）
1. pack_parser 按真实 CMSIS-Pack schema 重写（Dname/Dfamily、子元素 name/vendor、
   releases/release[1]/@version、memory+algorithm 提取 flash 范围）；
2. 用真实 Keil.STM32F1xx_DFP.pack 做集成测试夹具；
3. 新增 ScanPacks / 在线 SearchPacks（Keil pidx）RPC，填充 download_url；
4. DownloadPack：http/https 白名单 + basename 净化 + 分块下载进度 + Range 续传 + SHA256；
5. 前端补 installPack/scanPacks 封装，接通 Import/Scan 按钮。

### 3.3 后端进程与通信加固（对应 Bug#11/12/17）
1. server 绑定 127.0.0.1；端口 0 自动分配 + stdout 打印 `READY <port>` 握手，前端解析；
2. pyocd connect 传 `blocking=False`；
3. BackendManager 用绝对路径解析；监听窗口关闭事件调用 stop()；exitCode 监听 + 心跳 + 自动重启 + UI 横幅；
4. 共享状态加锁（Bug#23）。

### 3.4 前端状态与 UI 一致性（对应 Bug#13/15/16/21/22/27）
1. device_provider 迁移到 pack_provider 的 clearXxx copyWith 模式；
2. FlashState 增加 operationType / success；
3. 历史单一数据源（后端），前端补 SHA256（或后端计算）；
4. settingsProvider 的 driver/frequency/protocol 真正下发（connect/flash 请求携带）；
5. 频率统一 Hz；地址输入按 hex 解析 + 范围校验（结合 Pack 芯片 flash_base/size 做越界拦截——设计 S6 要求）。

### 3.5 工程化（对应 Bug#25/30/31/34）
1. CI：proto 生成一致性校验（git diff --exit-code）、服务器启动真实探测、Windows PyInstaller 产物 smoke（启动 + grpc health）；
2. 清理死代码/重复测试脚本；统一版本号来源（pubspec → UI 读取）；
3. 字体打包 assets；i18n 全量走 AppStrings，清除硬编码中文与 'Coming Soon' 残留。

---

## 4. 补充功能开发建议

> 对照设计文档（S1-S6）与 README 承诺的差距，按用户价值排序。

| # | 功能 | 现状 | 建议 |
|---|---|---|---|
| 1 | 固件预览入口 | 页面已写但不可达（Bug#6） | 烧录卡片加"预览"按钮 + 修复 HEX 分页语义 |
| 2 | 设备详情展示 | GetProbeDetails 后端已实现，前端未接 | 设备页探针卡显示固件/硬件版本、目标电压（README 已宣传） |
| 3 | 芯片选择器联动 | 目标芯片是手填文本框 | 从已装 Pack 芯片列表出下拉/搜索选择，自动带出 flash_base/size 做地址校验（设计 S3） |
| 4 | 在线 Pack 搜索下载 | 端到端缺失（Bug#7） | Keil pidx 索引 + 下载 + 自动安装 |
| 5 | 扇区级擦除 | 协议/驱动/UI 三层都缺（Bug#14） | EraseRequest 加地址范围；UI 输入扇区起止 |
| 6 | 烧录校验（Verify） | VERIFYING 相位定义了但从未使用 | pyocd program 后 verify_image / FileProgrammer 默认校验结果显式上报 |
| 7 | 后端健康监控 | 设计 S6 要求心跳+自动重连+断开提示 | 定时 checkHealth + 断开横幅 + 一键重启按钮 |
| 8 | 历史一键重烧 | 仅回填路径 | 恢复完整参数（地址/芯片）并可直接触发烧录；补 CSV 导出（ui-enhancement-report 4.4 已规划） |
| 9 | UF2 支持 | picker 已允许、链路无支持（Bug#26） | 实现 UF2 解析（FAMILY_ID 校验）或移除入口 |
| 10 | OpenOCD 驱动可用化 | 不可达且实现粗糙（Bug#10） | 完成 telnet 会话管理 + 从 Pack 推导 target cfg；未达标前 UI 置灰 |
| 11 | Windows 打包验证 | CI 有 job 但产物未 smoke | 发布前在真机验证 server.exe + bitsdojo 窗口 + file_picker |
| 12 | 长期候选 | — | RTT/串口监视、多探针批量烧录、Flash 回读保存、hex 编辑器（ui-enhancement-report 已调研） |

---

## 5. 验证记录

| 检查项 | 结果 |
|---|---|
| flutter analyze | ✅ No issues found (5.3s) |
| flutter test | ✅ 2/2 通过 |
| backend pytest（parsers/pack/drivers） | ✅ 21/21 通过（含假阳性，见 Bug#34） |
| DapFlashService 实例化（venv） | ✅ drivers=['pyocd','openocd'] |
| pyocd.pack 导入 | ❌ ModuleNotFoundError（实证 Bug#10/34 关联） |
| progress_handler(0.5) | ❌ TypeError（实证 Bug#1） |
| 真实格式 PDSC 解析 | ❌ name=Unknown, chips=0（实证 Bug#2） |
| HEX 预览 offset=0 | ❌ 全 FF 填充（实证 Bug#6） |
| ELF get_file_info | ❌ 报为 bin（实证 Bug#6） |
| pyocd frequency 单位 | Hz，默认 1000000（实证 Bug#4） |

> 注：本轮未连接真实 DAP-Link 硬件，烧录/擦除/复位的端到端行为基于 pyocd 0.45.1 源码与
> 运行时实证推断；建议修复 Bug#1/#4 后在真实硬件上回归。
