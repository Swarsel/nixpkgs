{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "bring-api";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "miaucl";
    repo = "bring-api";
    tag = finalAttrs.version;
    hash = "sha256-EwOb+AkjpJSpINFmfWNDqRPF7MDpwDa0LK3LFj7U/sY=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
    python-dotenv
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "bring_api" ];

  meta = {
    description = "Module to access the Bring! shopping lists API";
    homepage = "https://github.com/miaucl/bring-api";
    changelog = "https://github.com/miaucl/bring-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
