{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  meteocalc,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioecowitt";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "aioecowitt";
    tag = version;
    hash = "sha256-xnF2Zn0XfV7elYGPCfY0WKzmDyFKXU3yh6Bab7llbzw=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    meteocalc
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioecowitt" ];

  meta = {
    description = "Wrapper for the EcoWitt protocol";
    homepage = "https://github.com/home-assistant-libs/aioecowitt";
    changelog = "https://github.com/home-assistant-libs/aioecowitt/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
