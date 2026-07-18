{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  eth-hash,
  eth-utils,
  hexbytes,
  # nativeCheckInputs
  hypothesis,
  pydantic,
  pytest-xdist,
  pytestCheckHook,
  rlp,
  setuptools,
  sortedcontainers,
}:

buildPythonPackage rec {
  pname = "trie";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "py-trie";
    tag = "v${version}";
    hash = "sha256-QDywlAyFbQGgkATVifdixlnob4Tmsvr/VZ1rafzWKrU=";
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
    eth-hash
    eth-utils
    hexbytes
    rlp
    sortedcontainers
  ];

  disabledTestPaths = [ "tests/core/test_iter.py" ];

  disabledTests = [
    # some core tests require fixture submodule and execution spec
    "test_fixtures_exist"
    "test_bin_trie_update_value"
    "test_branch_updates"
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "trie" ];

  meta = {
    description = "Python library which implements the Ethereum Trie structure";
    homepage = "https://github.com/ethereum/py-trie";
    changelog = "https://github.com/ethereum/py-trie/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
