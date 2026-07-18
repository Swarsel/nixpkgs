{
  lib,
  fetchFromGitHub,
  # python module stuff
  buildPythonPackage,
  # dependencies
  cached-property,
  ckzg,
  eth-bloom,
  eth-keys,
  eth-typing,
  eth-utils,
  # nativeCheckInputs
  factory-boy,
  hypothesis,
  lru-dict,
  py-ecc,
  pycryptodome,
  pydantic,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  rlp,
  setuptools,
  trie,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-evm";
  version = "0.12.1-beta.1";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "py-evm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n2F0ApdmIED0wrGuNN45lyb7cGu8pRn8mLDehT7Ru9E=";
  };

  nativeCheckInputs = [
    factory-boy
    hypothesis
    pytestCheckHook
    pytest-xdist
    pycryptodome
  ];

  build-system = [ setuptools ];

  dependencies = [
    cached-property
    ckzg
    eth-bloom
    eth-keys
    eth-typing
    eth-utils
    lru-dict
    pydantic
    py-ecc
    rlp
    trie
  ];

  # py-evm project has been archived by upstream; its support should be deprecated from "3.14".
  disabled = pythonAtLeast "3.14";

  disabledTestPaths = [
    # json-fixtures require fixture submodule and execution spec
    "tests/json-fixtures"
  ];

  disabledTests = [
    # side-effect: runs pip online check and is blocked by sandbox
    "test_install_local_wheel"
  ];

  pyproject = true;

  pytestFlags = [
    # 'asyncio.iscoroutinefunction' is deprecated and slated for removal in Python 3.16; use inspect.iscoroutinefunction() instead
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "eth" ];

  meta = {
    description = "Python implementation of the Ethereum Virtual Machine";
    homepage = "https://github.com/ethereum/py-evm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
})
