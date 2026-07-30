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
