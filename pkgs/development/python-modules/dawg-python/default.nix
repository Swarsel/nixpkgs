{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dawg-python";
  version = "0.7.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Sl4yhuYmHMoC8gXP1VFqerEBkPowxRwo00WAj1leNCE=";
    pname = "DAWG-Python";
  };

  format = "setuptools";
  pythonImportsCheck = [ "dawg_python" ];

  meta = {
    description = "Pure Python reader for DAWGs created by dawgdic C++ library or DAWG Python extension";
    homepage = "https://github.com/pytries/DAWG-Python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
