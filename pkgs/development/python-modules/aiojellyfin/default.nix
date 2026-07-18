{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytest-aiohttp,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiojellyfin";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "Jc2k";
    repo = "aiojellyfin";
    tag = "v${version}";
    hash = "sha256-C2jIP2q+1z6iQoK18jRVaFKXtxyF1RXZMtXWakx7qO0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiojellyfin" ];

  meta = {
    description = "";
    homepage = "https://github.com/Jc2k/aiojellyfin";
    changelog = "https://github.com/Jc2k/aiojellyfin/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
