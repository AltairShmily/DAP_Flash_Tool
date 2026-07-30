import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from drivers.base import BaseDriver, ProbeInfo, ChipInfo
from drivers.openocd_driver import OpenOCDDriver

try:
    from drivers.pyocd_driver import PyOCDDriver
    HAS_PYOCD = True
except ImportError:
    HAS_PYOCD = False

def test_base_class():
    """Verify BaseDriver is abstract."""
    try:
        BaseDriver()
        print("FAIL: BaseDriver should not be instantiable")
        sys.exit(1)
    except TypeError:
        print("BaseDriver is abstract OK")

def test_pyocd_init():
    if not HAS_PYOCD:
        print("PyOCD driver init SKIPPED (pyocd not installed)")
        return
    driver = PyOCDDriver()
    assert not driver.is_connected()
    print("PyOCD driver init OK")

def test_openocd_init():
    driver = OpenOCDDriver()
    assert not driver.is_connected()
    print("OpenOCD driver init OK")

if __name__ == "__main__":
    test_base_class()
    test_pyocd_init()
    test_openocd_init()
    print("All driver tests passed!")
