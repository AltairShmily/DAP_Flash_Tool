"""ELF Parser - Parses ELF firmware files.

Supports reading and parsing .elf files using pyelftools,
extracting sections, symbols, and binary data for flashing.
"""

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
