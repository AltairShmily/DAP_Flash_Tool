"""BIN Parser - Parses raw binary firmware files.

Supports reading raw .bin files. Since binary files have no metadata,
a base_address must be provided (defaults to STM32 flash start 0x08000000).
"""

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
