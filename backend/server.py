"""DAP Flash Tool - gRPC Backend Server

Combined servicer using mixin classes for code organization while
maintaining a single DapFlashService gRPC registration.
"""

import sys
import os
import time
from concurrent import futures

_backend_dir = os.path.dirname(__file__)
sys.path.insert(0, _backend_dir)
sys.path.insert(0, os.path.join(_backend_dir, 'proto'))

import grpc
from proto import dap_flash_pb2_grpc
from services.device_service import DeviceServiceMixin
from services.flash_service import FlashServiceMixin
from services.pack_service import PackServiceMixin
from services.file_service import FileServiceMixin


class DapFlashService(
    DeviceServiceMixin,
    FlashServiceMixin,
    PackServiceMixin,
    FileServiceMixin,
    dap_flash_pb2_grpc.DapFlashServiceServicer,
):
    """Combined gRPC servicer implementing all DapFlashService RPCs."""

    def __init__(self):
        self._init_drivers()
        self._init_pack_manager()
        self._init_flash_history()


def serve(port: int = 50051):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    service = DapFlashService()
    dap_flash_pb2_grpc.add_DapFlashServiceServicer_to_server(service, server)
    # Localhost only: the service is unauthenticated by design (see docs S2).
    bound_port = server.add_insecure_port(f"127.0.0.1:{port}")
    if bound_port == 0:
        print(f"ERROR: failed to bind 127.0.0.1:{port}", flush=True)
        sys.exit(1)
    server.start()
    # Handshake line consumed by the Flutter BackendManager.
    print(f"READY {bound_port}", flush=True)
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        print("Shutting down...")
        server.stop(0)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 50051
    serve(port)
