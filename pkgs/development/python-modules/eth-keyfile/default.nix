{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  eth-keys,
  eth-utils,
  py-ecc,
  pycryptodome,
  pydantic,
  # nativeCheckInputs
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eth-keyfile";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-keyfile";
    tag = "v${version}";
    hash = "sha256-DR17EupRDnviN6OXF+B+RlCVdG8cfcvnIgIEKxrXFKs=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
    pydantic
  ];

  build-system = [ setuptools ];

  dependencies = [
    eth-keys
    eth-utils
    pycryptodome
    py-ecc
  ];

  disabledTests = [
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_keyfile" ];

  meta = {
    description = "Tools for handling the encrypted keyfile format used to store private keys";
    homepage = "https://github.com/ethereum/eth-keyfile";
    changelog = "https://github.com/ethereum/eth-keyfile/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
