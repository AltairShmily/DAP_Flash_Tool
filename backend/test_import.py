import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from proto import dap_flash_pb2, dap_flash_pb2_grpc

# Verify message types exist
probe = dap_flash_pb2.Probe(id="test", name="CMSIS-DAP")
print(f"Proto import OK: {probe}")

# Verify more types
req = dap_flash_pb2.ConnectRequest(probe_id="abc", target="stm32", frequency=1000000, protocol="swd")
print(f"ConnectRequest OK: {req}")
