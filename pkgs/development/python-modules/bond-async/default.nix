{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bond-async";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "bondhome";
    repo = "bond-async";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YRJHUOYFLf4dtQGIFKHLdUQxWTnZzG1MPirMsGvDor8=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "bond_async" ];

  meta = {
    description = "Asynchronous Python wrapper library over Bond Local API";
    homepage = "https://github.com/bondhome/bond-async";
    changelog = "https://github.com/bondhome/bond-async/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
