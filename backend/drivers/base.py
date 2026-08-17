from abc import ABC, abstractmethod
from typing import Callable, Optional
from dataclasses import dataclass


@dataclass
class ProbeInfo:
    id: str
    name: str
    vendor: str
    serial_number: str
    firmware_version: str = ""
    hardware_version: str = ""
    target_voltage: float = 0.0
    is_connected: bool = False


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
    def reset_software(self) -> None:
        """Software reset via DAP command."""
        ...

    @abstractmethod
    def reset_hardware(self) -> None:
        """Hardware reset via DAP reset pin."""
        ...

    @abstractmethod
    def read_chip_id(self) -> ChipInfo:
        """Read chip ID."""
        ...

    @abstractmethod
    def install_pack(self, pack_path: str) -> bool:
        """Install a CMSIS pack."""
        ...

    @abstractmethod
    def list_installed_packs(self) -> list[dict]:
        """List installed packs."""
        ...
