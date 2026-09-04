"""File Service - Handles firmware file operations.

Provides gRPC service methods for:
- Previewing firmware files in hex format
- Getting firmware file information

Only firmware files (.bin/.hex/.elf) are accessible through these RPCs to
limit the blast radius of the unauthenticated localhost gRPC interface.
"""

import os

import grpc

from proto import dap_flash_pb2
from parsers.hex_preview import preview_hex, get_file_info

_ALLOWED_EXTENSIONS = ('.bin', '.hex', '.elf')


def _validate_firmware_path(file_path: str) -> str:
    """Return the normalized path or raise ValueError for non-firmware files."""
    path = os.path.realpath(file_path)
    if not path.lower().endswith(_ALLOWED_EXTENSIONS):
        raise ValueError(
            f"Not a firmware file (allowed extensions: {', '.join(_ALLOWED_EXTENSIONS)})"
        )
    if not os.path.isfile(path):
        raise FileNotFoundError(f"File not found: {file_path}")
    return path


class FileServiceMixin:
    """File operations for the gRPC servicer."""

    def PreviewFirmware(self, request, context):
        """Preview firmware file in hex format."""
        try:
            path = _validate_firmware_path(request.file_path)
            hex_dump = preview_hex(
                path,
                offset=request.offset,
                length=request.length,
            )
            file_info = get_file_info(path)
            return dap_flash_pb2.PreviewResponse(
                hex_dump=hex_dump,
                total_size=file_info['total_size'],
                file_format=file_info['format'],
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INVALID_ARGUMENT, str(e))

    def GetFileInfo(self, request, context):
        """Get firmware file information."""
        try:
            path = _validate_firmware_path(request.file_path)
            info = get_file_info(path)
            return dap_flash_pb2.FileInfo(
                format=info['format'],
                total_size=info['total_size'],
                base_address=info['base_address'],
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INVALID_ARGUMENT, str(e))
