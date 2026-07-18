{
  lib,
  fetchFromGitHub,
  # nativeCheckInputs
  asn1tools,
  buildPythonPackage,
  coincurve,
  eth-hash,
  # dependencies
  eth-typing,
  eth-utils,
  factory-boy,
  hypothesis,
  isPyPy,
  pyasn1,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eth-keys";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-keys";
    tag = "v${version}";
    hash = "sha256-H/s/D4f4tqP/WTil9uLmFw2Do9sEjMWwEreQEooeszQ=";
  };

  nativeCheckInputs = [
    asn1tools
    factory-boy
    hypothesis
    pyasn1
    pytestCheckHook
    pydantic
  ]
  ++ optional-dependencies.coincurve
  ++ lib.optionals (!isPyPy) eth-hash.optional-dependencies.pysha3
  ++ lib.optionals isPyPy eth-hash.optional-dependencies.pycryptodome;

  build-system = [ setuptools ];

  dependencies = [
    eth-typing
    eth-utils
  ];

  disabledTests = [ "test_install_local_wheel" ];

  optional-dependencies = {
    coincurve = [ coincurve ];
  };

  pyproject = true;
  pythonImportsCheck = [ "eth_keys" ];

  meta = {
    description = "Common API for Ethereum key operations";
    homepage = "https://github.com/ethereum/eth-keys";
    changelog = "https://github.com/ethereum/eth-keys/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hellwolf ];
  };
}
