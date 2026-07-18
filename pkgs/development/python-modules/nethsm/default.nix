{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  cryptography,
  poetry-core,
  pycryptodome,
  pytestCheckHook,
  python-dateutil,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "nethsm";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = "nethsm-sdk-py";
    tag = "v${version}";
    hash = "sha256-1bU3C8dlErDpHQIqsEabi92VPC91/wTNvZnx2dDHcmw=";
  };

  nativeCheckInputs = [
    pycryptodome
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    certifi
    cryptography
    python-dateutil
    typing-extensions
    urllib3
  ];

  disabledTestPaths = [
    # Tests require a running Docker instance
    "tests/test_nethsm_config.py"
    "tests/test_nethsm_keys.py"
    "tests/test_nethsm_namespaces.py"
    "tests/test_nethsm_other.py"
    "tests/test_nethsm_system.py"
    "tests/test_nethsm_users.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nethsm" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Client-side Python SDK for NetHSM";
    homepage = "https://github.com/Nitrokey/nethsm-sdk-py";
    changelog = "https://github.com/Nitrokey/nethsm-sdk-py/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
