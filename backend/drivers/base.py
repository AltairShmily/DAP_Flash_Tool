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


# callback(progress, message, bytes_written, total_bytes)
# bytes_written/total_bytes are -1 when the driver cannot report them.
FlashProgressCallback = Callable[[float, str, int, int], None]


class BaseDriver(ABC):
    """Driver abstraction base class.

    Drivers only provide probe/flash capabilities. Pack management lives in
    pack.pack_manager.PackManager and must not depend on driver state.
    """

    @abstractmethod
    def list_probes(self) -> list[ProbeInfo]:
        """List available debug probes."""
        ...

    @abstractmethod
    def connect(self, probe_id: str, target: str, frequency: int, protocol: str = "swd") -> None:
        """Connect to target device. frequency is in Hz."""
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
    def flash(self, file_path: str, address: int, callback: FlashProgressCallback) -> None:
        """Flash firmware.

        address is the base address for raw binary files (ignored for HEX/ELF
        which carry their own addresses). address <= 0 means "use file/target default".
        """
        ...

    @abstractmethod
    def erase(self, mode: str = "chip",
              start_address: Optional[int] = None,
              length: Optional[int] = None) -> None:
        """Erase flash. mode: 'chip' or 'sector'.

        Sector mode requires start_address and length.
        """
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
