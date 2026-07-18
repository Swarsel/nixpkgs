{
  lib,
  fetchFromGitHub,
  aiohttp,
  asyncclick,
  buildPythonPackage,
  cryptography,
  hatchling,
  kasa-crypt,
  mashumaro,
  orjson,
  ptpython,
  pytest-asyncio,
  pytest-freezer,
  pytest-mock,
  pytest-socket,
  pytest-xdist,
  pytestCheckHook,
  rich,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "python-kasa";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "python-kasa";
    repo = "python-kasa";
    tag = version;
    hash = "sha256-OIkqNGTnIPoHYrE5NhAxSsRCTyMGvNADvIg28EuKsEw=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-freezer
    pytest-mock
    pytest-socket
    pytest-xdist
    pytestCheckHook
    voluptuous
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    asyncclick
    cryptography
    mashumaro
  ];

  disabledTestPaths = [
    # Skip the examples tests
    "tests/test_readme_examples.py"
    # Failing on hydra
    "tests/test_cli.py"
  ];

  optional-dependencies = {
    shell = [
      ptpython
      rich
    ];

    speedups = [
      kasa-crypt
      orjson
    ];
  };

  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "kasa" ];

  meta = {
    description = "Python API for TP-Link Kasa Smarthome products";
    homepage = "https://python-kasa.readthedocs.io/";
    changelog = "https://github.com/python-kasa/python-kasa/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "kasa";
  };
}
