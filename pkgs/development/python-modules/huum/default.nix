{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "huum";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "frwickst";
    repo = "pyhuum";
    tag = finalAttrs.version;
    hash = "sha256-f3ijcH9eou1upzBfvXNzrswFVoegSx81JxtlYVSnS6Q=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
  ]
  ++ aiohttp.optional-dependencies.speedups;

  pyproject = true;
  pythonImportsCheck = [ "huum" ];

  meta = {
    description = "Library for Huum saunas";
    homepage = "https://github.com/frwickst/pyhuum";
    changelog = "https://github.com/frwickst/pyhuum/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
