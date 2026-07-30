from typing import Callable
from pyocd.core.helpers import ConnectHelper
from pyocd.flash.file_programmer import FileProgrammer
from pyocd.flash.eraser import FlashEraser

from .base import BaseDriver, ProbeInfo, ChipInfo


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
