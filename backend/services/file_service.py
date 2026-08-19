"""File Service - Handles firmware file operations.

Provides gRPC service methods for:
- Previewing firmware files in hex format
- Getting firmware file information
"""

import os
import grpc

from proto import dap_flash_pb2
from parsers.hex_preview import preview_hex, get_file_info


class FileServiceMixin:
    """File operations for the gRPC servicer."""

    def PreviewFirmware(self, request, context):
        """Preview firmware file in hex format."""
        try:
            hex_dump = preview_hex(
                request.file_path,
                offset=request.offset,
                length=request.length,
            )
            file_info = get_file_info(request.file_path)
            return dap_flash_pb2.PreviewResponse(
                hex_dump=hex_dump,
                total_size=file_info['total_size'],
                file_format=file_info['format'],
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INTERNAL, str(e))

    def GetFileInfo(self, request, context):
        """Get firmware file information."""
        try:
            info = get_file_info(request.file_path)
            return dap_flash_pb2.FileInfo(
                format=info['format'],
                total_size=info['total_size'],
                base_address=info['base_address'],
            )
        except Exception as e:
            context.abort(grpc.StatusCode.INTERNAL, str(e))
