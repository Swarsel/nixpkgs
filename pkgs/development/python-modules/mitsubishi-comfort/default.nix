{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mitsubishi-comfort";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "nikolairahimi";
    repo = "mitsubishi-comfort";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fdP2E6ICxuaOUlNJxAa7k0WICWmxKtRFfB2eKRdanG8=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "mitsubishi_comfort" ];

  meta = {
    description = "Async Python library for Mitsubishi minisplit control via Kumo Cloud and local API";
    homepage = "https://github.com/nikolairahimi/mitsubishi-comfort";
    changelog = "https://github.com/nikolairahimi/mitsubishi-comfort/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
