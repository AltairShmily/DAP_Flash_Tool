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
        # In CMSIS packs, devices can be nested: <device family="X"><device name="Y">
        # or directly under <devices>. We look for all <device> elements with a 'name' attribute.
        # Build parent map for looking up family attribute from parent device.
        parent_map = {c: p for p in root.iter() for c in p}
        chips = []
        for device in root.findall('.//devices//device'):
            chip_name = device.get('name', '')
            if not chip_name:
                continue  # Skip family-level grouping elements
            chip_vendor = device.get('Dvendor', pack_vendor)
            # Family: from this element, or from parent device element
            chip_family = device.get('family', '')
            if not chip_family:
                parent = parent_map.get(device)
                if parent is not None:
                    chip_family = parent.get('family', '')

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
                family=chip_family,
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
