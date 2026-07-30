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
