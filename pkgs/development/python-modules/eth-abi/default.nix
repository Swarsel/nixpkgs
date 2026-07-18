{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  eth-hash,
  # dependencies
  eth-typing,
  eth-utils,
  # nativeCheckInputs
  hypothesis,
  parsimonious,
  pydantic,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eth-abi";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-abi";
    tag = "v${version}";
    hash = "sha256-/tyGm/lH72oZEKfTd25t+k0y3TuAZQg+hUABT4YCP2g=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-xdist
    pydantic
  ]
  ++ eth-hash.optional-dependencies.pycryptodome;

  build-system = [ setuptools ];

  dependencies = [
    eth-typing
    eth-utils
    parsimonious
  ];

  disabledTests = [
    # boolean list representation changed
    "test_get_abi_strategy_returns_certain_strategies_for_known_type_strings"
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_abi" ];
  pythonRelaxDeps = [ "parsimonious" ];

  meta = {
    description = "Ethereum ABI utilities";
    homepage = "https://github.com/ethereum/eth-abi";
    changelog = "https://github.com/ethereum/eth-abi/blob/v${version}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
