{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-unifi-access";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "imhotep";
    repo = "py-unifi-access";
    tag = finalAttrs.version;
    hash = "sha256-UxnW37JqUugdMix9MM5coHZvN9iTCmI53o7LfLL6t6M=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "unifi_access_api" ];

  meta = {
    description = "Async Python client for the UniFi Access local API with WebSocket event support";
    homepage = "https://github.com/imhotep/py-unifi-access";
    changelog = "https://github.com/imhotep/py-unifi-access/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
