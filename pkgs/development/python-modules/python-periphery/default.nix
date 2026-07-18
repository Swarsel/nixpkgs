{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "python-periphery";
  version = "2.4.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YdRh1zaYKm92boeHIKsQpoFR4ujBCGYA2TiaxH5A6Io=";
  };

  # Some tests require physical probing and additional physical setup
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Linux Peripheral I/O (GPIO, LED, PWM, SPI, I2C, MMIO, Serial) with Python 2 & 3";
    homepage = "https://github.com/vsergeev/python-periphery";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bandresen ];
  };
}
