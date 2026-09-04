import os
from typing import Optional

from pyocd.core.helpers import ConnectHelper
from pyocd.flash.file_programmer import FileProgrammer
from pyocd.flash.eraser import FlashEraser

from .base import BaseDriver, ProbeInfo, ChipInfo, FlashProgressCallback


def _safe(fn, default):
    """Call fn(); return default on any exception (probe properties may
    require an open connection)."""
    try:
        value = fn()
        return value if value is not None else default
    except Exception:
        return default


class PyOCDDriver(BaseDriver):
    def __init__(self):
        self._session = None

    def _probe_to_info(self, probe) -> ProbeInfo:
        return ProbeInfo(
            id=probe.unique_id,
            name=_safe(lambda: probe.product_name, "Unknown") or "Unknown",
            vendor=_safe(lambda: probe.vendor_name, "Unknown") or "Unknown",
            serial_number=probe.unique_id,
            firmware_version=str(_safe(lambda: probe.firmware_version, "") or ""),
            hardware_version=str(_safe(lambda: probe.hardware_version, "") or ""),
            target_voltage=float(_safe(lambda: probe.target_voltage, 0.0) or 0.0),
        )

    def list_probes(self) -> list[ProbeInfo]:
        probes = ConnectHelper.get_all_connected_probes()
        return [self._probe_to_info(p) for p in probes]

    def get_probe_details(self, probe_id: str) -> ProbeInfo:
        for probe in ConnectHelper.get_all_connected_probes():
            if probe.unique_id == probe_id:
                return self._probe_to_info(probe)
        raise ValueError(f"Probe {probe_id} not found")

    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        if self._session is not None:
            self.disconnect()

        options = {}
        if protocol in ("swd", "jtag"):
            options["dap_protocol"] = protocol
        if frequency and frequency > 0:
            options["frequency"] = int(frequency)
        if target:
            options["target_override"] = target

        # blocking=False: fail immediately instead of hanging the gRPC worker
        # waiting for a probe to appear or presenting a CLI selection menu.
        session = ConnectHelper.session_with_chosen_probe(
            unique_id=probe_id,
            blocking=False,
            options=options,
        )
        if session is None:
            raise RuntimeError(f"Probe '{probe_id}' not found")
        session.open()
        self._session = session

    def disconnect(self) -> None:
        if self._session:
            try:
                self._session.close()
            finally:
                self._session = None

    def is_connected(self) -> bool:
        return self._session is not None

    def flash(self, file_path: str, address: int, callback: FlashProgressCallback) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"Firmware file not found: {file_path}")

        total_bytes = os.path.getsize(file_path)

        # pyocd calls the progress handler with ONE argument: fraction 0.0-1.0
        def progress_handler(fraction: float) -> None:
            fraction = max(0.0, min(1.0, float(fraction)))
            written = int(fraction * total_bytes) if total_bytes else -1
            callback(fraction, f"Programming {fraction * 100:.1f}%", written, total_bytes)

        kwargs = {}
        # base_address only applies to raw binary images; HEX/ELF carry their
        # own addresses. pyocd ignores the kwarg for other formats.
        if file_path.lower().endswith(".bin") and address and address > 0:
            kwargs["base_address"] = int(address)

        FileProgrammer(self._session, progress=progress_handler).program(file_path, **kwargs)

        self._session.target.reset_and_halt()
        self._session.target.resume()

    def erase(self, mode: str = "chip",
              start_address: Optional[int] = None,
              length: Optional[int] = None) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")

        if mode == "sector":
            if not start_address or not length or length <= 0:
                raise ValueError("Sector erase requires start_address and length")
            eraser = FlashEraser(self._session, mode=FlashEraser.Mode.SECTOR)
            eraser.erase([f"0x{int(start_address):x}+0x{int(length):x}"])
        else:
            eraser = FlashEraser(self._session, mode=FlashEraser.Mode.CHIP)
            eraser.erase()

    def reset(self) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")
        self._session.target.reset()

    def reset_software(self) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")
        self._session.target.reset()

    def reset_hardware(self) -> None:
        if not self._session:
            raise RuntimeError("Not connected to any probe")
        self._session.target.reset_and_halt()
        self._session.target.resume()

    def read_chip_id(self) -> ChipInfo:
        if not self._session:
            raise RuntimeError("Not connected to any probe")

        target = self._session.target
        chip_id = target.read32(0xE0042000)  # DBGMCU_IDCODE (STM32 family)
        if chip_id == 0:
            # Fallback: ARM core CPUID, meaningful for any Cortex-M target
            cpuid = target.read32(0xE000ED00)
            return ChipInfo(chip_id=cpuid, description=f"CPUID: 0x{cpuid:08X}")
        return ChipInfo(chip_id=chip_id, description=f"ID: 0x{chip_id:08X}")
