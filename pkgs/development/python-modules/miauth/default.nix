{
  lib,
  # dependencies
  bluepy,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  # checks
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "miauth";
  version = "0.9.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2/4nFInpdY8fb/b+sXhgT6ZPtEgBV+KHMyLnxIp6y/U=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    bluepy
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "miauth" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "Authenticate and interact with Xiaomi devices over BLE";
    homepage = "https://github.com/dnandha/miauth";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "miauth";
  };
}
