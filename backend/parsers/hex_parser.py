"""HEX Parser - Parses Intel HEX firmware files.

Supports reading and parsing .hex files using the intelhex library,
extracting binary data, start addresses, and memory regions.
"""

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
