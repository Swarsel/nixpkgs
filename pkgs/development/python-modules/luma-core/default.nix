{
  lib,
  buildPythonPackage,
  cbor2,
  fetchPypi,
  pillow,
  pyftdi,
  rpi-gpio,
  setuptools,
  smbus2,
  spidev,
}:
buildPythonPackage rec {
  pname = "luma-core";
  version = "2.5.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7PscEvwy+O5s/w9hOASyYJOHwXVH9znQAmSfLm1W7C8=";
    pname = "luma_core";
  };

  build-system = [ setuptools ];

  dependencies = [
    pillow
    smbus2
    cbor2
  ]
  ++ optional-dependencies.complete;

  optional-dependencies = {
    complete = with optional-dependencies; gpio ++ spi ++ ftdi;
    ftdi = [ pyftdi ];
    gpio = [ rpi-gpio ];
    spi = [ spidev ];
  };

  pyproject = true;

  meta = {
    description = "Pillow-compatible drawing canvas library for SBCs";

    longDescription = ''
      A component library providing a Pillow-compatible drawing canvas,
      and other functionality to support drawing primitives and text-rendering
      capabilities for small displays on the Raspberry Pi and other single
      board computers.
    '';

    homepage = "https://luma-core.readthedocs.io/";
    changelog = "https://github.com/rm-hull/luma.core/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eymeric ];
  };
}
