{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  packaging,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiolyric";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "timmo001";
    repo = "aiolyric";
    tag = finalAttrs.version;
    hash = "sha256-+OYMe63sX5TtvJpNn6dzvnephlhS/MyFXmUerYZqF5A=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    packaging
  ];

  disabledTestPaths = [
    # _version file is no shipped
    "tests/test__version.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiolyric" ];

  pythonRelaxDeps = [
    "packaging"
  ];

  meta = {
    description = "Python module for the Honeywell Lyric Platform";
    homepage = "https://github.com/timmo001/aiolyric";
    changelog = "https://github.com/timmo001/aiolyric/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
