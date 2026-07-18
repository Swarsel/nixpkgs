{
  lib,
  attrs,
  buildPythonPackage,
  click,
  fetchPypi,
  jsons,
  packbits,
  pillow,
  pyusb,
  setuptools,
}:

buildPythonPackage rec {
  pname = "brother-ql";
  version = "0.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-NTw5hlMJRoABvbteyCYF0Kopc9AjNyuwLSB+zS3RYRQ=";
    pname = "brother_ql_next";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    attrs
    click
    jsons
    packbits
    pillow
    pyusb
  ];

  pyproject = true;

  meta = {
    description = "Python package for the raster language protocol of the Brother QL series label printers";

    longDescription = ''
      Python package for the raster language protocol of the Brother QL series label printers
      (QL-500, QL-550, QL-570, QL-700, QL-710W, QL-720NW, QL-800, QL-820NWB, QL-1050 and more)
    '';

    homepage = "https://github.com/LunarEclipse363/brother_ql_next";
    license = lib.licenses.gpl3Only;
    mainProgram = "brother_ql";
  };
}
