{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  isodate,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cookidoo-api";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "miaucl";
    repo = "cookidoo-api";
    tag = finalAttrs.version;
    hash = "sha256-3o+UZmS2Mfymqgl7qa1MSani2O/fiEfvQ0GQp7MBOOg=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
    python-dotenv
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "cookidoo_api" ];

  meta = {
    description = "Unofficial package to access Cookidoo";
    homepage = "https://github.com/miaucl/cookidoo-api";
    changelog = "https://github.com/miaucl/cookidoo-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
