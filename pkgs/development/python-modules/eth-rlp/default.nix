{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  eth-hash,
  eth-utils,
  hexbytes,
  pydantic,
  pytestCheckHook,
  rlp,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eth-rlp";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-rlp";
    rev = "v${version}";
    hash = "sha256-e8nPfxk3OnFEcPnfTy1IEUCHVId6E/ssNOUeAe331+U=";
  };

  propagatedBuildInputs = [
    hexbytes
    eth-utils
    rlp
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pydantic
  ]
  ++ eth-hash.optional-dependencies.pycryptodome;

  build-system = [ setuptools ];

  disabledTests = [
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_rlp" ];

  meta = {
    description = "RLP definitions for common Ethereum objects";
    homepage = "https://github.com/ethereum/eth-rlp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
