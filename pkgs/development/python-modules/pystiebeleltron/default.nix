{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pymodbus,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pystiebeleltron";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "ThyMYthOS";
    repo = "python-stiebel-eltron";
    tag = "v${version}";
    hash = "sha256-ApFhqJsYC/Kym1ITq5dn0/OQ6++led6RbG97DGvno0k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-mock
  ];

  build-system = [ hatchling ];
  dependencies = [ pymodbus ];

  disabledTestPaths = [
    # mock server is not compatible with pymodbus 3.13
    "test/test_pystiebeleltron.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pystiebeleltron" ];

  meta = {
    description = "Python API for interacting with the Stiebel Eltron ISG web gateway via Modbus";
    homepage = "https://github.com/ThyMYthOS/python-stiebel-eltron";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
