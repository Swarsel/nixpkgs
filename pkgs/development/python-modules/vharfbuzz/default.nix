{
  lib,
  buildPythonPackage,
  fetchPypi,
  fonttools,
  setuptools,
  setuptools-scm,
  uharfbuzz,
}:

buildPythonPackage rec {
  pname = "vharfbuzz";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zFVw8Nxh7cRJNk/S7D3uiIGShBMiZ/JeuSdX4hN94kc=";
  };

  # Package has no tests.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    uharfbuzz
  ];

  pyproject = true;
  pythonImportsCheck = [ "vharfbuzz" ];

  meta = {
    description = "Utility for removing hinting data from TrueType and OpenType fonts";
    homepage = "https://github.com/source-foundry/dehinter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
