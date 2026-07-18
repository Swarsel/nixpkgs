{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  eth-utils,
  hypothesis,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rlp";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "pyrlp";
    rev = "v${version}";
    hash = "sha256-moerdcAJXqhlzDnTlvxL3Nzz485tOzJVCPlGrof80eQ=";
  };

  propagatedBuildInputs = [ eth-utils ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pydantic
  ];

  build-system = [ setuptools ];
  disabledTests = [ "test_install_local_wheel" ];
  pyproject = true;
  pythonImportsCheck = [ "rlp" ];

  meta = {
    description = "RLP serialization library";
    homepage = "https://github.com/ethereum/pyrlp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
