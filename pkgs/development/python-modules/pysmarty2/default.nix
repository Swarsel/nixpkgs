{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pymodbus,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysmarty2";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "martinssipenko";
    repo = "pysmarty2";
    tag = "v${version}";
    hash = "sha256-an66TysXGPfKq9bPozwLM3M9E2sq3CC1if/uc47Ns5w=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pymodbus ];
  pyproject = true;
  pythonImportsCheck = [ "pysmarty2" ];

  meta = {
    description = "Python API for Salda Smarty Modbus TCP";
    homepage = "https://github.com/martinssipenko/pysmarty2";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
