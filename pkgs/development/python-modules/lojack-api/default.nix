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
  pname = "lojack-api";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "devinslick";
    repo = "lojack_api";
    tag = finalAttrs.version;
    hash = "sha256-QVXiIN+gb/jm5H49ByT8+jVgl3RVKPSgpwca04C6Keo=";
  };

  nativeCheckInputs = [
    aioresponses
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "lojack_api" ];

  meta = {
    description = "Async Python client library for the Spireon LoJack API";
    homepage = "https://github.com/devinslick/lojack_api";
    changelog = "https://github.com/devinslick/lojack_api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
