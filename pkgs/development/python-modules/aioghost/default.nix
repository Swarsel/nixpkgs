{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatchling,
  pyjwt,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioghost";
  version = "0.4.18";

  src = fetchFromGitHub {
    owner = "TryGhost";
    repo = "aioghost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4YmIsXegv23ZVpvewixJVR6IY8YqQzeLKDAjHTp937k=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioghost" ];

  meta = {
    description = "Async Python client for the Ghost Admin API";
    homepage = "https://github.com/TryGhost/aioghost";
    changelog = "https://github.com/TryGhost/aioghost/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
