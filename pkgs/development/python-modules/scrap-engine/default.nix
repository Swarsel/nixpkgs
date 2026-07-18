{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "scrap-engine";
  version = "1.5.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vw3nCxU6KTGR1qCB2TZTT4Y40q2++orp2tKsJkSWpAA=";
    pname = "scrap_engine";
  };

  # raise scrap_engine.CoordinateError
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "scrap_engine" ];

  meta = {
    description = "2D ascii game engine for the terminal";
    homepage = "https://github.com/lxgr-linux/scrap_engine";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fgaz ];
  };
}
