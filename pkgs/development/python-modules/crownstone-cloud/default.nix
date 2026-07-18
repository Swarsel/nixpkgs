{
  lib,
  aiohttp,
  buildPythonPackage,
  certifi,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "crownstone-cloud";
  version = "1.4.11";

  src = fetchPypi {
    inherit version;
    hash = "sha256-s84pK52uMupxQfdMldV14V3nj+yVku1Vw13CRX4o08U=";
    pname = "crownstone_cloud";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    certifi
  ];

  pyproject = true;
  pythonImportsCheck = [ "crownstone_cloud" ];

  meta = {
    description = "Python module for communicating with Crownstone Cloud and devices";
    homepage = "https://github.com/Crownstone-Community/crownstone-lib-python-cloud";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
