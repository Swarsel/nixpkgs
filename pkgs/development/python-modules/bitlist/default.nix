{
  lib,
  buildPythonPackage,
  fetchPypi,
  parts,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bitlist";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mbXSvIUYsnZy/pmZLFXa1bqrwK+JZ2eySuDRCVAs1zk=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ parts ];
  pyproject = true;
  pythonImportsCheck = [ "bitlist" ];
  pythonRelaxDeps = [ "parts" ];

  meta = {
    description = "Python library for working with little-endian list representation of bit strings";
    homepage = "https://github.com/lapets/bitlist";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
