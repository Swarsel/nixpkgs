{
  lib,
  aiomisc,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  pytest,
}:

buildPythonPackage rec {
  pname = "aiomisc-pytest";
  version = "1.3.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9Of1pSUcMiIhkz7OW5erF4oDlf/ABkaamDBPg7+WbBE=";
    pname = "aiomisc_pytest";
  };

  buildInputs = [ pytest ];
  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ aiomisc ];
  pyproject = true;
  pythonImportsCheck = [ "aiomisc_pytest" ];
  pythonRelaxDeps = [ "pytest" ];

  meta = {
    description = "Pytest integration for aiomisc";
    homepage = "https://github.com/aiokitchen/aiomisc-pytest";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
