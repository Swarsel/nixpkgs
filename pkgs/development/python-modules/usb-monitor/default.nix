{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyudev,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "usb-monitor";
  version = "1.23";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7xZ30JLPduY0y2SHWI7fvZHB27FbNFAMczHMXnaXl88=";
    pname = "usb_monitor";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyudev ];
  pyproject = true;
  pythonImportsCheck = [ "usbmonitor" ];

  meta = {
    description = "Cross-platform library for USB device monitoring";
    homepage = "https://github.com/Eric-Canas/USBMonitor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sifmelcara ];
    platforms = lib.platforms.linux;
  };
})
