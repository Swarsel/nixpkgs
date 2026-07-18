{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  eth-abi,
  eth-account,
  eth-hash,
  # tests
  eth-tester,
  eth-typing,
  eth-utils,
  flaky,
  hexbytes,
  hypothesis,
  # optional-dependencies
  ipfshttpclient,
  jsonschema,
  lru-dict,
  protobuf,
  py-evm,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pyunormalize,
  requests,
  # build-system
  setuptools,
  types-requests,
  websockets,
}:

buildPythonPackage rec {
  pname = "web3";
  version = "7.15.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "web3.py";
    tag = "v${version}";
    hash = "sha256-BStkLH7lCnhVs2Fc3c0EBXzyZtEgI8ywA01OEBYLUeQ=";
  };

  nativeCheckInputs = [
    eth-tester
    flaky
    hypothesis
    py-evm
    pytest-asyncio
    pytest-mock
    pytest-xdist
    pytestCheckHook
    pyunormalize
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    eth-abi
    eth-account
    eth-hash
  ]
  ++ eth-hash.optional-dependencies.pycryptodome
  ++ [
    eth-typing
    eth-utils
    hexbytes
    jsonschema
    lru-dict
    protobuf
    pydantic
    requests
    types-requests
    websockets
  ];

  disabledTestPaths = [
    # requires geth library and binaries
    "tests/integration/go_ethereum"

    # requires local running beacon node
    "tests/beacon"
  ];

  disabledTests = [
    # side-effect: runs pip online check and is blocked by sandbox
    "test_install_local_wheel"

    # not sure why they fail
    "test_async_init_multiple_contracts_performance"
    "test_init_multiple_contracts_performance"

    # AssertionError: assert '/build/geth.ipc' == '/tmp/geth.ipc
    "test_get_dev_ipc_path"

    # Require network access
    "test_websocket_provider_timeout"
  ];

  # Note: to reflect the extra_requires in main/setup.py.
  optional-dependencies = {
    ipfs = [ ipfshttpclient ];
  };

  pyproject = true;
  pythonImportsCheck = [ "web3" ];

  pythonRelaxDeps = [
    "websockets"
  ];

  meta = {
    description = "Python interface for interacting with the Ethereum blockchain and ecosystem";
    homepage = "https://web3py.readthedocs.io/";
    changelog = "https://web3py.readthedocs.io/en/stable/release_notes.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
