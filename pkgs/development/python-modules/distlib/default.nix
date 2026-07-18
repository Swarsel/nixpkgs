{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "distlib";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/uxAB1vgOgRQGpc9gfYzc1tLafmLBUUFkjEMD0AaTg0=";
  };

  nativeBuildInputs = [ setuptools ];
  # Tests use pypi.org.
  doCheck = false;

  postFixup = lib.optionalString (!stdenv.hostPlatform.isWindows) ''
    find $out -name '*.exe' -delete
  '';

  pyproject = true;

  pythonImportsCheck = [
    "distlib"
    "distlib.database"
    "distlib.locators"
    "distlib.index"
    "distlib.markers"
    "distlib.metadata"
    "distlib.util"
    "distlib.resources"
  ];

  meta = {
    description = "Low-level components of distutils2/packaging";
    homepage = "https://distlib.readthedocs.io";
    license = lib.licenses.psfl;
    maintainers = [ ];
  };
}
