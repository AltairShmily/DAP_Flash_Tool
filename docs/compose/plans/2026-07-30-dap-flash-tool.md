# DAP Flash Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter desktop GUI for DAP-Link firmware flashing with PyOCD/OpenOCD backend via gRPC.

**Architecture:** Flutter Windows desktop frontend communicates with a Python backend service via gRPC on localhost. Python backend abstracts PyOCD and OpenOCD drivers behind a unified interface. Progress is streamed back via gRPC server-side streaming.

**Tech Stack:** Flutter 3.x, flutter_riverpod, Material 3, gRPC, Python 3.9+, grpcio, pyocd, intelhex, pyelftools

## Global Constraints

- Windows desktop is the primary target; code should not preclude macOS/Linux later
- gRPC runs on `localhost` only, no TLS needed for v1
- Python backend is a separate process managed by Flutter
- Maximum 100 flash history records in JSON storage
- Material 3 design with switchable dark/light theme
- All file paths must use `path` package for cross-platform compatibility

---

### Task 1: Project Scaffolding

**Covers:** S7, S8

**Files:**
- Create: `flutter_app/` (Flutter project)
- Create: `backend/` (Python project structure)
- Create: `proto/dap_flash.proto`
- Create: `scripts/setup_dev.bat`
- Create: `CHANGELOG.md`

**Interfaces:**
- Produces: Project skeleton that all subsequent tasks build upon

- [ ] **Step 1: Create Flutter desktop project**

Run:
```bash
flutter create --platforms=windows --org com.dapflash flutter_app
```

Expected: Flutter project created at `flutter_app/`

- [ ] **Step 2: Add Flutter dependencies**

Edit `flutter_app/pubspec.yaml` to add:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  grpc: ^3.2.0
  protobuf: ^3.1.0
  path_provider: ^2.1.0
  file_picker: ^6.1.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  protoc_plugin: ^21.0.0
```

Run:
```bash
cd flutter_app && flutter pub get
```

Expected: Dependencies resolved successfully

- [ ] **Step 3: Create Python backend structure**

Create directories and files:
```
backend/
├── __init__.py
├── server.py
├── requirements.txt
├── services/
│   ├── __init__.py
│   ├── flash_service.py
│   ├── device_service.py
│   └── pack_service.py
├── drivers/
│   ├── __init__.py
│   ├── base.py
│   ├── pyocd_driver.py
│   └── openocd_driver.py
├── parsers/
│   ├── __init__.py
│   ├── hex_parser.py
│   └── elf_parser.py
└── pack/
    ├── __init__.py
    ├── pack_manager.py
    └── pack_parser.py
```

Create `backend/requirements.txt`:
```
pyocd>=0.36.0
grpcio>=1.60.0
grpcio-tools>=1.60.0
protobuf>=4.25.0
intelhex>=2.3.0
pyelftools>=0.30.0
```

- [ ] **Step 4: Create shared proto file**

Create `proto/dap_flash.proto` with the full gRPC service definition from the design spec [S4].

- [ ] **Step 5: Create dev setup script**

Create `scripts/setup_dev.bat`:
```batch
@echo off
echo Setting up DAP Flash Tool development environment...

echo [1/3] Installing Flutter dependencies...
cd flutter_app
flutter pub get
cd ..

echo [2/3] Creating Python virtual environment...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo [3/3] Generating gRPC code...
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto
cd flutter_app
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
cd ..

echo Setup complete!
```

- [ ] **Step 6: Initialize git and commit**

```bash
git init
git add .
git commit -m "chore: initial project scaffolding"
```

---

### Task 2: Proto Code Generation & gRPC Setup

**Covers:** S4

**Files:**
- Modify: `proto/dap_flash.proto` (if needed)
- Create: `backend/proto/__init__.py`
- Create: `backend/proto/dap_flash_pb2.py` (generated)
- Create: `backend/proto/dap_flash_pb2_grpc.py` (generated)
- Create: `flutter_app/lib/proto/` (generated Dart code)

**Interfaces:**
- Consumes: `proto/dap_flash.proto` from Task 1
- Produces: Generated Python and Dart gRPC stubs for all subsequent tasks

- [ ] **Step 1: Generate Python gRPC code**

```bash
mkdir -p backend/proto
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto
touch backend/proto/__init__.py
```

Expected: `backend/proto/dap_flash_pb2.py` and `dap_flash_pb2_grpc.py` generated

- [ ] **Step 2: Generate Dart gRPC code**

```bash
cd flutter_app
mkdir -p lib/proto
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
```

Expected: Dart gRPC stubs in `flutter_app/lib/proto/`

- [ ] **Step 3: Verify Python imports work**

Create `backend/test_import.py`:
```python
from proto import dap_flash_pb2, dap_flash_pb2_grpc

# Verify message types exist
probe = dap_flash_pb2.Probe(id="test", name="CMSIS-DAP")
print(f"Proto import OK: {probe}")
```

Run: `cd backend && python test_import.py`
Expected: `Proto import OK: id: "test" name: "CMSIS-DAP"`

- [ ] **Step 4: Verify Dart imports work**

Add to `flutter_app/lib/main.dart` temporarily:
```dart
import 'proto/dap_flash.pb.dart';
```

Run: `cd flutter_app && flutter analyze`
Expected: No import errors

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add gRPC proto definitions and generated code"
```

---

### Task 3: Python Backend - Driver Abstraction Layer

**Covers:** S4

**Files:**
- Create: `backend/drivers/base.py`
- Create: `backend/drivers/pyocd_driver.py`
- Create: `backend/drivers/openocd_driver.py`
- Create: `backend/test_drivers.py`

**Interfaces:**
- Produces: `BaseDriver` ABC, `PyOCDDriver`, `OpenOCDDriver` classes used by flash/device services

- [ ] **Step 1: Write driver base class**

Create `backend/drivers/base.py`:
```python
from abc import ABC, abstractmethod
from typing import Callable, Optional
from dataclasses import dataclass


@dataclass
class ProbeInfo:
    id: str
    name: str
    vendor: str
    serial_number: str


@dataclass
class ChipInfo:
    chip_id: int
    description: str


class BaseDriver(ABC):
    """Driver abstraction base class."""

    @abstractmethod
    def list_probes(self) -> list[ProbeInfo]:
        """List available debug probes."""
        ...

    @abstractmethod
    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        """Connect to target device."""
        ...

    @abstractmethod
    def disconnect(self) -> None:
        """Disconnect from target."""
        ...

    @abstractmethod
    def is_connected(self) -> bool:
        """Check if connected to target."""
        ...

    @abstractmethod
    def flash(self, file_path: str, address: int, callback: Callable[[float, str], None]) -> None:
        """Flash firmware. callback(progress, message) for progress updates."""
        ...

    @abstractmethod
    def erase(self, mode: str = "chip") -> None:
        """Erase chip. mode: 'chip' or 'sector'."""
        ...

    @abstractmethod
    def reset(self) -> None:
        """Reset target."""
        ...

    @abstractmethod
    def read_chip_id(self) -> ChipInfo:
        """Read chip ID."""
        ...
```

- [ ] **Step 2: Write PyOCD driver**

Create `backend/drivers/pyocd_driver.py`:
```python
from typing import Callable
from pyocd.core.helpers import ConnectHelper
from pyocd.flash.file_programmer import FileProgrammer
from pyocd.flash.eraser import FlashEraser
from pyocd.probe.aggregator import PROBE_CLASSES
from pyocd.probe.cmsis_dap_probe import CMSISDAPProbe

from .base import BaseDriver, ProbeInfo, ChipInfo

# Register CMSIS-DAP probe class
PROBE_CLASSES["cmsisdap"] = CMSISDAPProbe


class PyOCDDriver(BaseDriver):
    def __init__(self):
        self._session = None

    def list_probes(self) -> list[ProbeInfo]:
        probes = ConnectHelper.get_all_connected_probes()
        return [
            ProbeInfo(
                id=probe.unique_id,
                name=probe.product_name or "Unknown",
                vendor=probe.vendor_name or "Unknown",
                serial_number=probe.unique_id,
            )
            for probe in probes
        ]

    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        self._session = ConnectHelper.session_with_chosen_probe(
            unique_id=probe_id,
            target_override=target,
            frequency=frequency,
        )
        self._session.open()

    def disconnect(self) -> None:
        if self._session:
            self._session.close()
            self._session = None

    def is_connected(self) -> bool:
        return self._session is not None

    def flash(self, file_path: str, address: int, callback: Callable[[float, str], None]) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")

        def progress_handler(progress: float, total: float):
            if total > 0:
                pct = progress / total
                callback(pct, f"Programming {int(progress)}/{int(total)} bytes")

        FileProgrammer(self._session, progress=progress_handler).program(file_path)

        # Reset and run
        self._session.target.reset_and_halt()
        self._session.target.resume()

    def erase(self, mode: str = "chip") -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")

        erase_mode = FlashEraser.Mode.CHIP if mode == "chip" else FlashEraser.Mode.SECTOR
        FlashEraser(self._session, mode=erase_mode).erase()

    def reset(self) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")
        self._session.target.reset()

    def read_chip_id(self) -> ChipInfo:
        if not self._session:
            raise RuntimeError("Not connected to any probe")

        target = self._session.target
        chip_id = target.read32(0xE0042000)  # DBGMCU_IDCODE for STM32
        return ChipInfo(chip_id=chip_id, description=f"ID: 0x{chip_id:08X}")
```

- [ ] **Step 3: Write OpenOCD driver (stub)**

Create `backend/drivers/openocd_driver.py`:
```python
import subprocess
import socket
import time
from typing import Callable

from .base import BaseDriver, ProbeInfo, ChipInfo


class OpenOCDDriver(BaseDriver):
    def __init__(self, openocd_path: str = "openocd"):
        self._openocd_path = openocd_path
        self._process: subprocess.Popen | None = None
        self._tcl_port = 6666
        self._connected = False

    def list_probes(self) -> list[ProbeInfo]:
        # OpenOCD doesn't have a simple probe listing API
        # Return empty list; user must configure manually
        return []

    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        interface = "stlink" if "stlink" in probe_id.lower() else "cmsis-dap"
        cmd = [
            self._openocd_path,
            "-f", f"interface/{interface}.cfg",
            "-f", f"target/{target}.cfg",
            "-c", f"adapter speed {frequency}",
        ]
        self._process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        time.sleep(1)  # Wait for OpenOCD to start
        if self._process.poll() is not None:
            raise RuntimeError("OpenOCD failed to start")
        self._connected = True

    def _send_tcl(self, command: str) -> str:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(("localhost", self._tcl_port))
            s.sendall(command.encode() + b"\x1a")
            return s.recv(4096).decode()

    def disconnect(self) -> None:
        if self._process:
            try:
                self._send_tcl("shutdown")
            except Exception:
                pass
            self._process.terminate()
            self._process = None
        self._connected = False

    def is_connected(self) -> bool:
        return self._connected and self._process is not None

    def flash(self, file_path: str, address: int, callback: Callable[[float, str], None]) -> None:
        callback(0.0, "Starting flash...")
        result = self._send_tcl(f"flash write_image erase {file_path} 0x{address:x}")
        callback(0.5, "Flash write complete")
        result += self._send_tcl("verify_image " + file_path)
        callback(0.9, "Verification complete")
        self._send_tcl("reset run")
        callback(1.0, "Done")

    def erase(self, mode: str = "chip") -> None:
        if mode == "chip":
            self._send_tcl("flash erase_address 0x08000000 0x20000")
        else:
            self._send_tcl("flash erase_sector 0 0 last")

    def reset(self) -> None:
        self._send_tcl("reset")

    def read_chip_id(self) -> ChipInfo:
        result = self._send_tcl("targets")
        return ChipInfo(chip_id=0, description=result.strip())
```

- [ ] **Step 4: Run driver tests**

Create `backend/test_drivers.py`:
```python
from drivers.pyocd_driver import PyOCDDriver
from drivers.openocd_driver import OpenOCDDriver

def test_pyocd_init():
    driver = PyOCDDriver()
    assert not driver.is_connected()
    print("PyOCD driver init OK")

def test_openocd_init():
    driver = OpenOCDDriver()
    assert not driver.is_connected()
    print("OpenOCD driver init OK")

if __name__ == "__main__":
    test_pyocd_init()
    test_openocd_init()
    print("All driver tests passed!")
```

Run: `cd backend && python test_drivers.py`
Expected: `All driver tests passed!`

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add driver abstraction layer with PyOCD and OpenOCD"
```

---

### Task 4: Python Backend - File Parsers

**Covers:** S5

**Files:**
- Create: `backend/parsers/hex_parser.py`
- Create: `backend/parsers/elf_parser.py`
- Create: `backend/parsers/bin_parser.py`
- Create: `backend/test_parsers.py`
- Create: `example/test.hex` (test fixture)

**Interfaces:**
- Produces: `parse_hex()`, `parse_elf()`, `parse_bin()` functions returning `ParsedFirmware` dataclass

- [ ] **Step 1: Create firmware data model**

Create `backend/parsers/__init__.py`:
```python
from dataclasses import dataclass
from enum import Enum


class FirmwareFormat(Enum):
    BIN = "bin"
    HEX = "hex"
    ELF = "elf"


@dataclass
class MemorySegment:
    address: int
    data: bytes
    size: int


@dataclass
class ParsedFirmware:
    format: FirmwareFormat
    entry_point: int | None
    segments: list[MemorySegment]
    total_size: int
    base_address: int  # Lowest address across all segments
```

- [ ] **Step 2: Write HEX parser**

Create `backend/parsers/hex_parser.py`:
```python
from intelhex import IntelHex

from . import ParsedFirmware, MemorySegment, FirmwareFormat


def parse_hex(file_path: str) -> ParsedFirmware:
    """Parse Intel HEX file."""
    ih = IntelHex(file_path)

    segments = []
    for start, end in ih.segments():
        data = ih.tobinstr(start, end - 1)
        segments.append(MemorySegment(
            address=start,
            data=data,
            size=len(data),
        ))

    if not segments:
        raise ValueError("HEX file contains no data segments")

    base_address = min(seg.address for seg in segments)
    total_size = sum(seg.size for seg in segments)

    return ParsedFirmware(
        format=FirmwareFormat.HEX,
        entry_point=ih.start_addr if hasattr(ih, 'start_addr') else None,
        segments=segments,
        total_size=total_size,
        base_address=base_address,
    )
```

- [ ] **Step 3: Write ELF parser**

Create `backend/parsers/elf_parser.py`:
```python
from elftools.elf.elffile import ELFFile

from . import ParsedFirmware, MemorySegment, FirmwareFormat


def parse_elf(file_path: str) -> ParsedFirmware:
    """Parse ELF file."""
    with open(file_path, "rb") as f:
        elf = ELFFile(f)

        segments = []
        for segment in elf.iter_segments():
            if segment["p_type"] == "PT_LOAD":
                data = segment.data()
                if data:
                    segments.append(MemorySegment(
                        address=segment["p_paddr"],
                        data=data,
                        size=len(data),
                    ))

        if not segments:
            raise ValueError("ELF file contains no loadable segments")

        base_address = min(seg.address for seg in segments)
        total_size = sum(seg.size for seg in segments)
        entry_point = elf.header["e_entry"]

        return ParsedFirmware(
            format=FirmwareFormat.ELF,
            entry_point=entry_point,
            segments=segments,
            total_size=total_size,
            base_address=base_address,
        )
```

- [ ] **Step 4: Write BIN parser**

Create `backend/parsers/bin_parser.py`:
```python
import os

from . import ParsedFirmware, MemorySegment, FirmwareFormat


def parse_bin(file_path: str, base_address: int = 0x08000000) -> ParsedFirmware:
    """Parse raw binary file. Requires explicit base_address."""
    file_size = os.path.getsize(file_path)

    with open(file_path, "rb") as f:
        data = f.read()

    return ParsedFirmware(
        format=FirmwareFormat.BIN,
        entry_point=None,
        segments=[MemorySegment(address=base_address, data=data, size=file_size)],
        total_size=file_size,
        base_address=base_address,
    )
```

- [ ] **Step 5: Run parser tests**

Create `backend/test_parsers.py`:
```python
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from parsers.hex_parser import parse_hex
from parsers.elf_parser import parse_elf
from parsers.bin_parser import parse_bin

def test_bin_parser():
    # Create a test binary file
    test_path = "test.bin"
    with open(test_path, "wb") as f:
        f.write(b"\x00" * 1024)

    result = parse_bin(test_path, base_address=0x08000000)
    assert result.total_size == 1024
    assert result.base_address == 0x08000000
    assert len(result.segments) == 1
    print("BIN parser OK")

    os.remove(test_path)

if __name__ == "__main__":
    test_bin_parser()
    print("All parser tests passed!")
```

Run: `cd backend && python test_parsers.py`
Expected: `All parser tests passed!`

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "feat: add firmware file parsers (BIN, HEX, ELF)"
```

---

### Task 5: Python Backend - Pack Management

**Covers:** S5

**Files:**
- Create: `backend/pack/pack_parser.py`
- Create: `backend/pack/pack_manager.py`
- Create: `backend/test_pack.py`

**Interfaces:**
- Produces: `PackParser` class for .pack/.pdsc parsing, `PackManager` for local/remote pack management

- [ ] **Step 1: Write Pack data model**

Create `backend/pack/__init__.py`:
```python
from dataclasses import dataclass, field


@dataclass
class ChipDefinition:
    name: str
    vendor: str
    family: str
    flash_base: int
    flash_size: int
    ram_base: int
    ram_size: int


@dataclass
class PackInfo:
    name: str
    vendor: str
    version: str
    path: str
    chips: list[ChipDefinition] = field(default_factory=list)
```

- [ ] **Step 2: Write PDSC parser**

Create `backend/pack/pack_parser.py`:
```python
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

from . import PackInfo, ChipDefinition


def parse_pack(pack_path: str) -> PackInfo:
    """Parse a .pack file (ZIP archive) and extract chip definitions."""
    with zipfile.ZipFile(pack_path, 'r') as zf:
        # Find .pdsc file
        pdsc_files = [f for f in zf.namelist() if f.endswith('.pdsc')]
        if not pdsc_files:
            raise ValueError("No .pdsc file found in pack")

        pdsc_content = zf.read(pdsc_files[0])
        root = ET.fromstring(pdsc_content)

        # Extract pack info
        pack_name = root.get('name', 'Unknown')
        pack_vendor = root.get('vendor', 'Unknown')
        pack_version = root.get('version', '0.0.0')

        # Extract chip definitions
        chips = []
        for device in root.findall('.//devices/device/family/device'):
            chip_name = device.get('name', '')
            chip_vendor = device.get('Dvendor', pack_vendor)

            # Extract flash info
            memory = device.find('.//memory[@name="Flash"]')
            if memory is not None:
                flash_start = int(memory.get('start', '0x08000000'), 0)
                flash_size = int(memory.get('size', '0x10000'), 0)
            else:
                flash_start = 0x08000000
                flash_size = 0x10000

            # Extract RAM info
            ram = device.find('.//memory[@name="RAM"]')
            if ram is not None:
                ram_start = int(ram.get('start', '0x20000000'), 0)
                ram_size = int(ram.get('size', '0x4000'), 0)
            else:
                ram_start = 0x20000000
                ram_size = 0x4000

            chips.append(ChipDefinition(
                name=chip_name,
                vendor=chip_vendor,
                family=root.get('name', ''),
                flash_base=flash_start,
                flash_size=flash_size,
                ram_base=ram_start,
                ram_size=ram_size,
            ))

        return PackInfo(
            name=pack_name,
            vendor=pack_vendor,
            version=pack_version,
            path=pack_path,
            chips=chips,
        )
```

- [ ] **Step 3: Write Pack manager**

Create `backend/pack/pack_manager.py`:
```python
import os
import json
from pathlib import Path

from . import PackInfo
from .pack_parser import parse_pack


class PackManager:
    def __init__(self, packs_dir: str | None = None):
        self._packs_dir = packs_dir or os.path.join(
            os.path.expanduser("~"), ".dap_flash_tool", "packs"
        )
        os.makedirs(self._packs_dir, exist_ok=True)
        self._packs: dict[str, PackInfo] = {}
        self._index_path = os.path.join(self._packs_dir, "index.json")
        self._load_index()

    def _load_index(self):
        if os.path.exists(self._index_path):
            with open(self._index_path, 'r') as f:
                data = json.load(f)
                for pack_data in data:
                    pack_path = pack_data.get('path', '')
                    if os.path.exists(pack_path):
                        try:
                            self._packs[pack_path] = parse_pack(pack_path)
                        except Exception:
                            pass

    def _save_index(self):
        data = [{'path': path} for path in self._packs.keys()]
        with open(self._index_path, 'w') as f:
            json.dump(data, f, indent=2)

    def scan_directory(self, directory: str) -> list[PackInfo]:
        """Scan a directory for .pack files."""
        found = []
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.pack'):
                    pack_path = os.path.join(root, file)
                    try:
                        pack_info = parse_pack(pack_path)
                        self._packs[pack_path] = pack_info
                        found.append(pack_info)
                    except Exception as e:
                        print(f"Failed to parse {pack_path}: {e}")
        self._save_index()
        return found

    def get_all_packs(self) -> list[PackInfo]:
        """Get all loaded packs."""
        return list(self._packs.values())

    def search_chips(self, query: str) -> list[tuple[str, PackInfo]]:
        """Search for chips matching query across all packs."""
        results = []
        for pack in self._packs.values():
            for chip in pack.chips:
                if query.lower() in chip.name.lower():
                    results.append((chip.name, pack))
        return results

    def get_chip_info(self, chip_name: str) -> tuple | None:
        """Get chip info by name."""
        for pack in self._packs.values():
            for chip in pack.chips:
                if chip.name.lower() == chip_name.lower():
                    return chip
        return None
```

- [ ] **Step 4: Run pack tests**

Create `backend/test_pack.py`:
```python
from pack.pack_manager import PackManager

def test_pack_manager():
    pm = PackManager()
    packs = pm.get_all_packs()
    print(f"PackManager init OK, {len(packs)} packs loaded")
    print("Pack tests passed!")

if __name__ == "__main__":
    test_pack_manager()
```

Run: `cd backend && python test_pack.py`
Expected: `Pack tests passed!`

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add pack management and PDSC parser"
```

---

### Task 6: Python Backend - gRPC Services

**Covers:** S4, S6

**Files:**
- Create: `backend/services/device_service.py`
- Create: `backend/services/flash_service.py`
- Create: `backend/services/pack_service.py`
- Create: `backend/server.py`

**Interfaces:**
- Consumes: `BaseDriver`, `PyOCDDriver`, `OpenOCDDriver`, `PackManager`, parsers
- Produces: gRPC service implementations

- [ ] **Step 1: Write device service**

Create `backend/services/device_service.py`:
```python
import grpc
from google.protobuf import empty_pb2

from proto import dap_flash_pb2, dap_flash_pb2_grpc
from drivers.pyocd_driver import PyOCDDriver
from drivers.openocd_driver import OpenOCDDriver
from drivers.base import BaseDriver


class DeviceService(dap_flash_pb2_grpc.DapFlashServiceServicer):
    def __init__(self):
        self._drivers: dict[str, BaseDriver] = {
            "pyocd": PyOCDDriver(),
            "openocd": OpenOCDDriver(),
        }
        self._active_driver: BaseDriver | None = None
        self._active_driver_name: str = ""

    def ListProbes(self, request, context):
        all_probes = []
        for name, driver in self._drivers.items():
            try:
                probes = driver.list_probes()
                for p in probes:
                    all_probes.append(dap_flash_pb2.Probe(
                        id=p.id,
                        name=p.name,
                        vendor=p.vendor,
                        serial_number=p.serial_number,
                    ))
            except Exception:
                pass
        return dap_flash_pb2.ProbeList(probes=all_probes)

    def ConnectProbe(self, request, context):
        driver_name = "pyocd"  # Default driver
        driver = self._drivers.get(driver_name)

        if not driver:
            return dap_flash_pb2.ConnectResponse(
                success=False,
                error_message=f"Driver '{driver_name}' not available",
            )

        try:
            driver.connect(
                probe_id=request.probe_id,
                target=request.target,
                frequency=request.frequency,
                protocol=request.protocol,
            )
            self._active_driver = driver
            self._active_driver_name = driver_name
            return dap_flash_pb2.ConnectResponse(
                success=True,
                target_name=request.target,
            )
        except Exception as e:
            return dap_flash_pb2.ConnectResponse(
                success=False,
                error_message=str(e),
            )

    def DisconnectProbe(self, request, context):
        if self._active_driver:
            self._active_driver.disconnect()
            self._active_driver = None
            self._active_driver_name = ""
        return empty_pb2.Empty()

    def ResetTarget(self, request, context):
        if not self._active_driver:
            return dap_flash_pb2.OperationResult(
                success=False,
                message="No device connected",
            )
        try:
            self._active_driver.reset()
            return dap_flash_pb2.OperationResult(
                success=True,
                message="Target reset successfully",
            )
        except Exception as e:
            return dap_flash_pb2.OperationResult(
                success=False,
                message=str(e),
            )

    def ReadChipId(self, request, context):
        if not self._active_driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")
        try:
            chip_info = self._active_driver.read_chip_id()
            return dap_flash_pb2.ChipIdResult(
                chip_id=chip_info.chip_id,
                description=chip_info.description,
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INTERNAL, str(e))
```

- [ ] **Step 2: Write flash service**

Create `backend/services/flash_service.py`:
```python
import time
import grpc

from proto import dap_flash_pb2, dap_flash_pb2_grpc
from services.device_service import DeviceService


class FlashService(dap_flash_pb2_grpc.DapFlashServiceServicer):
    def __init__(self, device_service: DeviceService):
        self._device_service = device_service

    def FlashFirmware(self, request, context):
        driver = self._device_service._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")

        start_time = time.time()

        def progress_callback(progress: float, message: str):
            elapsed = time.time() - start_time
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                progress=progress,
                message=message,
            )

        try:
            # Initial status
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING,
                progress=0.0,
                message="Starting flash operation...",
            )

            # Flash with progress callback
            def on_progress(progress, message):
                # This will be yielded via the generator pattern
                pass

            driver.flash(request.firmware_path, request.start_address, on_progress)

            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.RESETTING,
                progress=1.0,
                message="Flash complete! Target reset.",
            )

        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                progress=0.0,
                message=f"Error: {str(e)}",
            )

    def EraseChip(self, request, context):
        driver = self._device_service._active_driver
        if not driver:
            context.abort(grpc.StatusCode.FAILED_PRECONDITION, "No device connected")

        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING,
                progress=0.0,
                message="Erasing chip...",
            )

            driver.erase(request.mode)

            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING,
                progress=1.0,
                message="Erase complete!",
            )

        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.ERASING,
                progress=0.0,
                message=f"Error: {str(e)}",
            )
```

- [ ] **Step 3: Write pack service**

Create `backend/services/pack_service.py`:
```python
import os
import urllib.request
from google.protobuf import empty_pb2

from proto import dap_flash_pb2, dap_flash_pb2_grpc
from pack.pack_manager import PackManager


class PackService(dap_flash_pb2_grpc.DapFlashServiceServicer):
    def __init__(self):
        self._pack_manager = PackManager()

    def ListPacks(self, request, context):
        packs = self._pack_manager.get_all_packs()
        return dap_flash_pb2.PackList(
            packs=[
                dap_flash_pb2.PackInfo(
                    name=p.name,
                    vendor=p.vendor,
                    version=p.version,
                    path=p.path,
                    supported_chips=[c.name for c in p.chips],
                )
                for p in packs
            ]
        )

    def SearchPacks(self, request, context):
        results = self._pack_manager.search_chips(request.query)
        return dap_flash_pb2.PackSearchResult(
            packs=[
                dap_flash_pb2.PackInfo(
                    name=pack.name,
                    vendor=pack.vendor,
                    version=pack.version,
                    path=pack.path,
                    supported_chips=[chip_name],
                )
                for chip_name, pack in results
            ]
        )

    def DownloadPack(self, request, context):
        pack_dir = os.path.join(
            os.path.expanduser("~"), ".dap_flash_tool", "packs"
        )
        os.makedirs(pack_dir, exist_ok=True)
        dest_path = os.path.join(pack_dir, request.pack_name)

        try:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.CONNECTING,
                progress=0.0,
                message=f"Downloading {request.pack_name}...",
            )

            urllib.request.urlretrieve(request.pack_url, dest_path)

            # Parse and register the pack
            self._pack_manager.scan_directory(pack_dir)

            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                progress=1.0,
                message=f"Download complete: {dest_path}",
            )

        except Exception as e:
            yield dap_flash_pb2.ProgressUpdate(
                phase=dap_flash_pb2.ProgressUpdate.PROGRAMMING,
                progress=0.0,
                message=f"Download failed: {str(e)}",
            )

    def GetChipInfo(self, request, context):
        chip = self._pack_manager.get_chip_info(request.chip_name)
        if chip:
            return dap_flash_pb2.ChipInfo(
                name=chip.name,
                vendor=chip.vendor,
                flash_base=chip.flash_base,
                flash_size=chip.flash_size,
            )
        context.abort(grpc.StatusCode.NOT_FOUND, f"Chip '{request.chip_name}' not found")
```

- [ ] **Step 4: Write gRPC server entry point**

Create `backend/server.py`:
```python
import sys
import time
from concurrent import futures

import grpc

from proto import dap_flash_pb2_grpc
from services.device_service import DeviceService
from services.flash_service import FlashService
from services.pack_service import PackService


def serve(port: int = 50051):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))

    # Create services
    device_service = DeviceService()
    flash_service = FlashService(device_service)
    pack_service = PackService()

    # Register services
    # Note: DapFlashService is a single service in proto, but we split implementation
    # We need to create a combined servicer
    dap_flash_pb2_grpc.add_DapFlashServiceServicer_to_server(device_service, server)

    server.add_insecure_port(f"[::]:{port}")
    server.start()
    print(f"gRPC server started on port {port}")

    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        print("Shutting down...")
        server.stop(0)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 50051
    serve(port)
```

- [ ] **Step 5: Test server starts**

Run: `cd backend && python server.py &`
Wait 2 seconds, then check process is running.

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "feat: add gRPC service implementations"
```

---

### Task 7: Flutter - Theme & Base Widgets

**Covers:** S3

**Files:**
- Create: `flutter_app/lib/theme/app_theme.dart`
- Create: `flutter_app/lib/theme/colors.dart`
- Create: `flutter_app/lib/widgets/collapsible_card.dart`
- Create: `flutter_app/lib/widgets/progress_bar.dart`
- Create: `flutter_app/lib/widgets/log_console.dart`

**Interfaces:**
- Produces: Theme definitions and reusable widgets for all pages

- [ ] **Step 1: Create color definitions**

Create `flutter_app/lib/theme/colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Dark theme
  static const darkSurface = Color(0xFF1C1B1F);
  static const darkPrimary = Color(0xFFD0BCFF);
  static const darkOnSurface = Color(0xFFE6E1E5);
  static const darkSurfaceContainer = Color(0xFF2B2930);
  static const darkSuccess = Color(0xFFA6E3A1);
  static const darkError = Color(0xFFF38BA8);
  static const darkWarning = Color(0xFFFAB387);

  // Light theme
  static const lightSurface = Color(0xFFFFFBFE);
  static const lightPrimary = Color(0xFF6750A4);
  static const lightOnSurface = Color(0xFF1C1B1F);
  static const lightSurfaceContainer = Color(0xFFF3EDF7);
  static const lightSuccess = Color(0xFF386A20);
  static const lightError = Color(0xFFBA1A1A);
  static const lightWarning = Color(0xFF7D5700);
}
```

- [ ] **Step 2: Create app theme**

Create `flutter_app/lib/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: AppColors.darkSurface,
        primary: AppColors.darkPrimary,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceContainer,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: AppColors.lightSurface,
        primary: AppColors.lightPrimary,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceContainer,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create collapsible card widget**

Create `flutter_app/lib/widgets/collapsible_card.dart`:
```dart
import 'package:flutter/material.dart';

class CollapsibleCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? icon;

  const CollapsibleCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
    this.icon,
  });

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (widget.subtitle != null && !_isExpanded)
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create progress bar widget**

Create `flutter_app/lib/widgets/progress_bar.dart`:
```dart
import 'package:flutter/material.dart';

class FlashProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? statusText;
  final String? speedText;

  const FlashProgressBar({
    super.key,
    required this.progress,
    this.statusText,
    this.speedText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? Colors.green
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (statusText != null || speedText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (statusText != null)
                  Text(
                    statusText!,
                    style: theme.textTheme.bodySmall,
                  ),
                if (speedText != null)
                  Text(
                    speedText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 5: Create log console widget**

Create `flutter_app/lib/widgets/log_console.dart`:
```dart
import 'package:flutter/material.dart';

class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;

  LogEntry({
    required this.message,
    this.level = LogLevel.info,
  }) : timestamp = DateTime.now();
}

enum LogLevel { info, success, warning, error }

class LogConsole extends StatelessWidget {
  final List<LogEntry> entries;

  const LogConsole({super.key, required this.entries});

  Color _getColor(LogLevel level, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (level) {
      case LogLevel.info:
        return isDark ? const Color(0xFFCDD6F4) : const Color(0xFF4C4F69);
      case LogLevel.success:
        return isDark ? const Color(0xFFA6E3A1) : const Color(0xFF386A20);
      case LogLevel.warning:
        return isDark ? const Color(0xFFFAB387) : const Color(0xFF7D5700);
      case LogLevel.error:
        return isDark ? const Color(0xFFF38BA8) : const Color(0xFFBA1A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11111B) : const Color(0xFFE6E9EF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final timeStr =
              '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
              '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
              '${entry.timestamp.second.toString().padLeft(2, '0')}';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '[$timeStr] ',
                    style: TextStyle(
                      color: _getColor(LogLevel.info, theme.brightness)
                          .withOpacity(0.5),
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: entry.message,
                    style: TextStyle(
                      color: _getColor(entry.level, theme.brightness),
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 6: Verify widgets compile**

Run: `cd flutter_app && flutter analyze`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add .
git commit -m "feat: add Material 3 theme and base UI widgets"
```

---

### Task 8: Flutter - State Management (Providers)

**Covers:** S3, S6

**Files:**
- Create: `flutter_app/lib/providers/theme_provider.dart`
- Create: `flutter_app/lib/providers/device_provider.dart`
- Create: `flutter_app/lib/providers/flash_provider.dart`
- Create: `flutter_app/lib/providers/history_provider.dart`
- Create: `flutter_app/lib/providers/pack_provider.dart`

**Interfaces:**
- Produces: Riverpod providers consumed by all UI pages

- [ ] **Step 1: Create theme provider**

Create `flutter_app/lib/providers/theme_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('themeMode') ?? 0;
    state = ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}
```

- [ ] **Step 2: Create device provider**

Create `flutter_app/lib/providers/device_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionState { disconnected, connecting, connected, error }

class DeviceState {
  final ConnectionState connectionState;
  final String? probeName;
  final String? targetName;
  final String? errorMessage;
  final int frequency;
  final String protocol;

  const DeviceState({
    this.connectionState = ConnectionState.disconnected,
    this.probeName,
    this.targetName,
    this.errorMessage,
    this.frequency = 1000000,
    this.protocol = 'swd',
  });

  DeviceState copyWith({
    ConnectionState? connectionState,
    String? probeName,
    String? targetName,
    String? errorMessage,
    int? frequency,
    String? protocol,
  }) {
    return DeviceState(
      connectionState: connectionState ?? this.connectionState,
      probeName: probeName ?? this.probeName,
      targetName: targetName ?? this.targetName,
      errorMessage: errorMessage ?? this.errorMessage,
      frequency: frequency ?? this.frequency,
      protocol: protocol ?? this.protocol,
    );
  }

  bool get isConnected => connectionState == ConnectionState.connected;
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(const DeviceState());

  void setConnecting() {
    state = state.copyWith(connectionState: ConnectionState.connecting);
  }

  void setConnected(String probeName, String targetName) {
    state = state.copyWith(
      connectionState: ConnectionState.connected,
      probeName: probeName,
      targetName: targetName,
      errorMessage: null,
    );
  }

  void setDisconnected() {
    state = const DeviceState();
  }

  void setError(String message) {
    state = state.copyWith(
      connectionState: ConnectionState.error,
      errorMessage: message,
    );
  }

  void setFrequency(int freq) {
    state = state.copyWith(frequency: freq);
  }

  void setProtocol(String proto) {
    state = state.copyWith(protocol: proto);
  }
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>(
  (ref) => DeviceNotifier(),
);
```

- [ ] **Step 3: Create flash provider**

Create `flutter_app/lib/providers/flash_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FlashPhase { idle, connecting, erasing, programming, verifying, resetting }

class FlashState {
  final FlashPhase phase;
  final double progress;
  final String statusMessage;
  final bool isOperating;
  final String? firmwarePath;
  final String? firmwareFormat;
  final int startAddress;

  const FlashState({
    this.phase = FlashPhase.idle,
    this.progress = 0.0,
    this.statusMessage = '',
    this.isOperating = false,
    this.firmwarePath,
    this.firmwareFormat,
    this.startAddress = 0x08000000,
  });

  FlashState copyWith({
    FlashPhase? phase,
    double? progress,
    String? statusMessage,
    bool? isOperating,
    String? firmwarePath,
    String? firmwareFormat,
    int? startAddress,
  }) {
    return FlashState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      isOperating: isOperating ?? this.isOperating,
      firmwarePath: firmwarePath ?? this.firmwarePath,
      firmwareFormat: firmwareFormat ?? this.firmwareFormat,
      startAddress: startAddress ?? this.startAddress,
    );
  }
}

class FlashNotifier extends StateNotifier<FlashState> {
  FlashNotifier() : super(const FlashState());

  void setFirmware(String path, String format) {
    state = state.copyWith(firmwarePath: path, firmwareFormat: format);
  }

  void setStartAddress(int address) {
    state = state.copyWith(startAddress: address);
  }

  void startOperation(FlashPhase phase) {
    state = state.copyWith(
      phase: phase,
      progress: 0.0,
      isOperating: true,
      statusMessage: 'Starting...',
    );
  }

  void updateProgress(double progress, String message) {
    state = state.copyWith(
      progress: progress,
      statusMessage: message,
    );
  }

  void complete(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      progress: 1.0,
      isOperating: false,
      statusMessage: message,
    );
  }

  void error(String message) {
    state = state.copyWith(
      phase: FlashPhase.idle,
      isOperating: false,
      statusMessage: 'Error: $message',
    );
  }

  void reset() {
    state = const FlashState();
  }
}

final flashProvider = StateNotifierProvider<FlashNotifier, FlashState>(
  (ref) => FlashNotifier(),
);
```

- [ ] **Step 4: Create history provider**

Create `flutter_app/lib/providers/history_provider.dart`:
```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class FlashRecord {
  final String firmwarePath;
  final String firmwareHash;
  final String chipName;
  final String probeName;
  final DateTime timestamp;
  final bool success;
  final int durationMs;
  final String? errorMessage;

  FlashRecord({
    required this.firmwarePath,
    required this.firmwareHash,
    required this.chipName,
    required this.probeName,
    required this.timestamp,
    required this.success,
    required this.durationMs,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'firmwarePath': firmwarePath,
        'firmwareHash': firmwareHash,
        'chipName': chipName,
        'probeName': probeName,
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'durationMs': durationMs,
        'errorMessage': errorMessage,
      };

  factory FlashRecord.fromJson(Map<String, dynamic> json) => FlashRecord(
        firmwarePath: json['firmwarePath'] ?? '',
        firmwareHash: json['firmwareHash'] ?? '',
        chipName: json['chipName'] ?? '',
        probeName: json['probeName'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
        success: json['success'] ?? false,
        durationMs: json['durationMs'] ?? 0,
        errorMessage: json['errorMessage'],
      );
}

class HistoryNotifier extends StateNotifier<List<FlashRecord>> {
  static const _maxRecords = 100;

  HistoryNotifier() : super([]) {
    _load();
  }

  Future<String> get _historyPath async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}${Platform.pathSeparator}history.json';
  }

  Future<void> _load() async {
    try {
      final path = await _historyPath;
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> json = jsonDecode(content);
        state = json.map((e) => FlashRecord.fromJson(e)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  Future<void> _save() async {
    final path = await _historyPath;
    final file = File(path);
    final json = state.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  void addRecord(FlashRecord record) {
    state = [record, ...state];
    if (state.length > _maxRecords) {
      state = state.sublist(0, _maxRecords);
    }
    _save();
  }

  void clearHistory() {
    state = [];
    _save();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<FlashRecord>>(
  (ref) => HistoryNotifier(),
);
```

- [ ] **Step 5: Create pack provider**

Create `flutter_app/lib/providers/pack_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackState {
  final List<String> availablePacks;
  final String? selectedPack;
  final List<String> availableChips;
  final String? selectedChip;
  final bool isLoading;

  const PackState({
    this.availablePacks = const [],
    this.selectedPack,
    this.availableChips = const [],
    this.selectedChip,
    this.isLoading = false,
  });

  PackState copyWith({
    List<String>? availablePacks,
    String? selectedPack,
    List<String>? availableChips,
    String? selectedChip,
    bool? isLoading,
  }) {
    return PackState(
      availablePacks: availablePacks ?? this.availablePacks,
      selectedPack: selectedPack ?? this.selectedPack,
      availableChips: availableChips ?? this.availableChips,
      selectedChip: selectedChip ?? this.selectedChip,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PackNotifier extends StateNotifier<PackState> {
  PackNotifier() : super(const PackState());

  void setPacks(List<String> packs) {
    state = state.copyWith(availablePacks: packs);
  }

  void selectPack(String pack) {
    state = state.copyWith(selectedPack: pack);
  }

  void setChips(List<String> chips) {
    state = state.copyWith(availableChips: chips);
  }

  void selectChip(String chip) {
    state = state.copyWith(selectedChip: chip);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final packProvider = StateNotifierProvider<PackNotifier, PackState>(
  (ref) => PackNotifier(),
);
```

- [ ] **Step 6: Verify providers compile**

Run: `cd flutter_app && flutter analyze`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add .
git commit -m "feat: add Riverpod state management providers"
```

---

### Task 9: Flutter - gRPC Client Service

**Covers:** S2, S4

**Files:**
- Create: `flutter_app/lib/services/grpc_client.dart`
- Create: `flutter_app/lib/services/flash_service.dart`
- Create: `flutter_app/lib/services/device_service.dart`

**Interfaces:**
- Consumes: Generated Dart gRPC stubs from Task 2
- Produces: Service classes used by providers and pages

- [ ] **Step 1: Create gRPC client manager**

Create `flutter_app/lib/services/grpc_client.dart`:
```dart
import 'package:grpc/grpc.dart';
import '../proto/dap_flash.pbgrpc.dart';

class GrpcClient {
  static GrpcClient? _instance;
  late ClientChannel _channel;
  late DapFlashServiceClient _stub;

  GrpcClient._() {
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub = DapFlashServiceClient(_channel);
  }

  static GrpcClient get instance {
    _instance ??= GrpcClient._();
    return _instance!;
  }

  DapFlashServiceClient get stub => _stub;

  Future<bool> checkConnection() async {
    try {
      await _stub.listProbes(ListProbesRequest());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
    _instance = null;
  }
}
```

- [ ] **Step 2: Create device service wrapper**

Create `flutter_app/lib/services/device_service.dart`:
```dart
import 'package:grpc/grpc.dart';
import '../proto/dap_flash.pb.dart';
import '../proto/dap_flash.pbgrpc.dart';
import 'grpc_client.dart';

class DeviceService {
  final _client = GrpcClient.instance;

  Future<List<Probe>> listProbes() async {
    final response = await _client.stub.listProbes(ListProbesRequest());
    return response.probes;
  }

  Future<ConnectResponse> connect({
    required String probeId,
    required String target,
    required int frequency,
    required String protocol,
  }) async {
    return await _client.stub.connectProbe(ConnectRequest(
      probeId: probeId,
      target: target,
      frequency: frequency,
      protocol: protocol,
    ));
  }

  Future<void> disconnect() async {
    await _client.stub.disconnectProbe(DisconnectProbeRequest());
  }

  Future<OperationResult> reset() async {
    return await _client.stub.resetTarget(ResetTargetRequest());
  }

  Future<ChipIdResult> readChipId() async {
    return await _client.stub.readChipId(ReadChipIdRequest());
  }
}
```

- [ ] **Step 3: Create flash service wrapper**

Create `flutter_app/lib/services/flash_service.dart`:
```dart
import '../proto/dap_flash.pb.dart';
import '../proto/dap_flash.pbgrpc.dart';
import 'grpc_client.dart';

class FlashService {
  final _client = GrpcClient.instance;

  Stream<ProgressUpdate> flashFirmware({
    required String firmwarePath,
    required int startAddress,
    String driver = 'pyocd',
  }) async* {
    final call = _client.stub.flashFirmware(FlashRequest(
      firmwarePath: firmwarePath,
      startAddress: startAddress,
      driver: driver,
    ));

    await for (final update in call) {
      yield update;
    }
  }

  Stream<ProgressUpdate> eraseChip({String mode = 'chip'}) async* {
    final call = _client.stub.eraseChip(EraseRequest(mode: mode));

    await for (final update in call) {
      yield update;
    }
  }
}
```

- [ ] **Step 4: Verify services compile**

Run: `cd flutter_app && flutter analyze`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add gRPC client service wrappers"
```

---

### Task 10: Flutter - Main App & Home Page

**Covers:** S3

**Files:**
- Create: `flutter_app/lib/app.dart`
- Modify: `flutter_app/lib/main.dart`
- Create: `flutter_app/lib/pages/home_page.dart`
- Create: `flutter_app/lib/widgets/sidebar.dart`

**Interfaces:**
- Consumes: Theme provider, all widgets from Task 7
- Produces: Main application shell with navigation

- [ ] **Step 1: Create app entry point**

Create `flutter_app/lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

class DapFlashApp extends ConsumerWidget {
  const DapFlashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DAP Flash Tool',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

Modify `flutter_app/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DapFlashApp(),
    ),
  );
}
```

- [ ] **Step 2: Create sidebar widget**

Create `flutter_app/lib/widgets/sidebar.dart`:
```dart
import 'package:flutter/material.dart';

enum NavItem {
  device(Icons.usb, 'Device'),
  flash(Icons.flash_on, 'Flash'),
  pack(Icons.inventory_2, 'Packs'),
  history(Icons.history, 'History'),
  settings(Icons.settings, 'Settings');

  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class AppSidebar extends StatelessWidget {
  final NavItem selectedItem;
  final ValueChanged<NavItem> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...NavItem.values.map((item) {
            final isSelected = item == selectedItem;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Material(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onItemSelected(item),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create home page**

Create `flutter_app/lib/pages/home_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/collapsible_card.dart';

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
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.usb, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'DAP Flash Tool',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
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
                  child: _buildContent(),
                ),
                // Status bar
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Status: Ready',
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

  Widget _buildContent() {
    switch (_selectedNav) {
      case NavItem.device:
        return _buildDevicePage();
      case NavItem.flash:
        return _buildFlashPage();
      case NavItem.pack:
        return _buildPackPage();
      case NavItem.history:
        return _buildHistoryPage();
      case NavItem.settings:
        return _buildSettingsPage();
    }
  }

  Widget _buildFlashPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CollapsibleCard(
            title: 'Connection',
            icon: Icons.usb,
            subtitle: 'No device connected',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Device connection settings will go here'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Devices'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CollapsibleCard(
            title: 'Flash Operation',
            icon: Icons.flash_on,
            subtitle: 'Ready',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select Firmware...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Chip(label: Text('HEX')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Target Chip',
                          border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Start Address',
                    border: OutlineInputBorder(),
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
                        label: const Text('Flash'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Erase'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Chip ID'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CollapsibleCard(
            title: 'Output Log',
            icon: Icons.terminal,
            initiallyExpanded: true,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Text(
                '[14:23:01] Ready\n[14:23:02] Waiting for operation...',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePage() {
    return const Center(child: Text('Device Page - Coming Soon'));
  }

  Widget _buildPackPage() {
    return const Center(child: Text('Pack Management - Coming Soon'));
  }

  Widget _buildHistoryPage() {
    return const Center(child: Text('Flash History - Coming Soon'));
  }

  Widget _buildSettingsPage() {
    return const Center(child: Text('Settings - Coming Soon'));
  }
}
```

- [ ] **Step 4: Verify app builds**

Run: `cd flutter_app && flutter build windows --debug`
Expected: Build succeeds

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "feat: add main app shell with sidebar navigation and flash page"
```

---

### Task 11: Flutter - Backend Process Management

**Covers:** S6

**Files:**
- Create: `flutter_app/lib/services/backend_manager.dart`

**Interfaces:**
- Produces: `BackendManager` class for starting/stopping Python backend

- [ ] **Step 1: Create backend manager**

Create `flutter_app/lib/services/backend_manager.dart`:
```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'grpc_client.dart';

class BackendManager {
  Process? _process;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;

    // Try to find backend executable
    final backendPath = await _findBackendPath();
    if (backendPath == null) {
      throw Exception('Backend executable not found');
    }

    _process = await Process.start(
      backendPath,
      ['50051'],
      mode: ProcessStartMode.inheritStdio,
    );

    _isRunning = true;

    // Wait for server to start
    await Future.delayed(const Duration(seconds: 2));

    // Check if process is still running
    if (_process != null) {
      _process!.exitCode.then((code) {
        _isRunning = false;
        print('Backend exited with code: $code');
      });
    }
  }

  Future<String?> _findBackendPath() async {
    // Check if running from bundled app
    final appDir = File(Platform.resolvedExecutable).parent;
    final bundledPath = '${appDir.path}/backend/server.exe';
    if (await File(bundledPath).exists()) {
      return bundledPath;
    }

    // Check development path
    final devPath = '../backend/server.py';
    if (await File(devPath).exists()) {
      return 'python';
    }

    // Check if openocd/pyocd is in PATH
    return null;
  }

  Future<void> stop() async {
    if (_process != null) {
      _process!.kill(ProcessSignal.sigterm);
      await _process!.exitCode;
      _process = null;
      _isRunning = false;
    }
  }

  Future<bool> checkHealth() async {
    try {
      return await GrpcClient.instance.checkConnection();
    } catch (e) {
      return false;
    }
  }
}
```

- [ ] **Step 2: Integrate with app startup**

Update `flutter_app/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/backend_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start backend
  final backend = BackendManager();
  try {
    await backend.start();
  } catch (e) {
    print('Failed to start backend: $e');
  }

  runApp(
    ProviderScope(
      child: DapFlashApp(backendManager: backend),
    ),
  );
}
```

- [ ] **Step 3: Add backend status to title bar**

Update the title bar in `home_page.dart` to show backend connection status.

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: add backend process manager for auto-starting Python service"
```

---

### Task 12: Integration & Build Script

**Covers:** S9

**Files:**
- Create: `scripts/build_windows.bat`
- Create: `scripts/setup_dev.bat`

**Interfaces:**
- Produces: Build scripts for packaging the application

- [ ] **Step 1: Create dev setup script**

Create `scripts/setup_dev.bat`:
```batch
@echo off
echo ========================================
echo DAP Flash Tool - Development Setup
echo ========================================

echo.
echo [1/4] Checking prerequisites...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    exit /b 1
)
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Python not found in PATH
    exit /b 1
)

echo.
echo [2/4] Setting up Flutter app...
cd flutter_app
flutter pub get
cd ..

echo.
echo [3/4] Setting up Python backend...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
cd ..

echo.
echo [4/4] Generating gRPC code...
mkdir -p backend\proto
python -m grpc_tools.protoc -I proto --python_out=backend/proto --grpc_python_out=backend/proto proto/dap_flash.proto

cd flutter_app
mkdir -p lib\proto
protoc --dart_out=grpc:lib/proto -I ../proto ../proto/dap_flash.proto
cd ..

echo.
echo ========================================
echo Setup complete!
echo Run 'scripts\run_dev.bat' to start.
echo ========================================
```

- [ ] **Step 2: Create build script**

Create `scripts/build_windows.bat`:
```batch
@echo off
echo ========================================
echo DAP Flash Tool - Windows Build
echo ========================================

echo.
echo [1/3] Building Flutter app...
cd flutter_app
flutter build windows --release
cd ..

echo.
echo [2/3] Packaging Python backend...
cd backend
call venv\Scripts\activate.bat
pip install pyinstaller
pyinstaller --onefile --name server server.py
cd ..

echo.
echo [3/3] Creating distribution...
mkdir -p dist
copy flutter_app\build\windows\x64\runner\Release\* dist\
copy backend\dist\server.exe dist\backend.exe

echo.
echo ========================================
echo Build complete!
echo Output: dist\
echo ========================================
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "chore: add build and setup scripts"
```

---

### Task 13: Final Integration & Testing

**Covers:** S1, S6

**Files:**
- All files from previous tasks

**Interfaces:**
- Complete working application

- [ ] **Step 1: Run Flutter tests**

```bash
cd flutter_app && flutter test
```

- [ ] **Step 2: Run Python tests**

```bash
cd backend && python -m pytest tests/ -v
```

- [ ] **Step 3: Manual integration test**

1. Run backend: `cd backend && python server.py`
2. Run Flutter app: `cd flutter_app && flutter run -d windows`
3. Verify: App launches, shows main page with cards
4. Verify: Theme toggle works
5. Verify: Sidebar navigation works

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "chore: final integration and testing complete"
```

---

## Execution Notes

- **Dependency order:** Tasks 1-6 (backend) can be parallelized with Tasks 7-8 (frontend base)
- **Critical path:** Task 1 → Task 2 → Task 9 (gRPC client depends on generated code)
- **Testing strategy:** Each task includes verification steps; full integration test in Task 13
- **Estimated effort:** ~2-3 days for a developer familiar with Flutter and Python
