{
  lib,
  fetchFromGitHub,
  aiohttp,
  bleak,
  bleak-retry-connector,
  bluetooth-adapters,
  buildPythonPackage,
  hatch-regex-commit,
  hatchling,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pynecil";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "tr4nt0r";
    repo = "pynecil";
    tag = "v${version}";
    hash = "sha256-nZaWiaEAIsubvSSsJZLQVfpaElWx7WKeRlYK80tUohg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    hatch-regex-commit
    hatchling
  ];

  dependencies = [
    aiohttp
    bleak
    bleak-retry-connector
    bluetooth-adapters
  ];

  disabledTests = [
    # requires access to system D-Bus
    "test_get_settings_communication_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pynecil" ];

  meta = {
    description = "Python library to communicate with Pinecil V2 soldering irons via Bluetooth";
    homepage = "https://github.com/tr4nt0r/pynecil";
    changelog = "https://github.com/tr4nt0r/pynecil/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
