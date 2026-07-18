{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  eth-hash,
  # nativeCheckInputs
  hypothesis,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eth-bloom";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-bloom";
    tag = "v${version}";
    hash = "sha256-WrBLFICPyb+1bIitHZ172A1p1VYqLR75YfJ5/IBqDr8=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-xdist
  ]
  ++ eth-hash.optional-dependencies.pycryptodome;

  build-system = [ setuptools ];
  dependencies = [ eth-hash ];

  disabledTests = [
    # not testable in nix build
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_bloom" ];

  meta = {
    description = "Implementation of the Ethereum bloom filter";
    homepage = "https://github.com/ethereum/eth-bloom";
    changelog = "https://github.com/ethereum/eth-bloom/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
