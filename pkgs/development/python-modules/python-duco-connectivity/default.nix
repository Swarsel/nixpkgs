{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-duco-connectivity";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "ronaldvdmeer";
    repo = "python-duco-connectivity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Txm7l7fVkEcUIX2J5CEF3OLLgTiT9O/xva0tSCCMZpI=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "duco_connectivity" ];

  meta = {
    description = "Async HTTP client for the local Duco Connectivity API";
    homepage = "https://github.com/ronaldvdmeer/python-duco-connectivity";
    changelog = "https://github.com/ronaldvdmeer/python-duco-connectivity/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
