{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  freezegun,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "imgw-pib";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "imgw-pib";
    tag = finalAttrs.version;
    hash = "sha256-KF9YQKGX6mTINZN09PNVLYFqMe1cITN4P9ge1Q+NGJk=";
  };

  nativeCheckInputs = [
    aiointercept
    aioresponses
    freezegun
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "imgw_pib" ];

  pythonRelaxDeps = [
    "aiohttp"
  ];

  meta = {
    description = "Python async wrapper for IMGW-PIB API";
    homepage = "https://github.com/bieniu/imgw-pib";
    changelog = "https://github.com/bieniu/imgw-pib/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
