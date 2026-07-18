{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
}:

buildPythonPackage rec {
  pname = "pyworld";
  version = "0.3.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-G5PlPN22eg5PqjTWz5GaxsZi/rHIwO2QHXG1las5aqM=";
  };

  nativeBuildInputs = [ cython ];
  propagatedBuildInputs = [ numpy ];
  format = "setuptools";
  pythonImportsCheck = [ "pyworld" ];

  meta = {
    description = "PyWorld is a Python wrapper for WORLD vocoder";
    homepage = "https://github.com/JeremyCCHsu/Python-Wrapper-for-World-Vocoder";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mic92 ];
  };
}
