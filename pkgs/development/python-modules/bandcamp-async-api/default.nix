{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "bandcamp-async-api";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "ALERTua";
    repo = "bandcamp_async_api";
    tag = finalAttrs.version;
    hash = "sha256-pL1V3xAcI48cgddf0tmE+djGI7sagGAI3w0Qu7/O8pI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    python-dotenv
    pytestCheckHook
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "bandcamp_async_api" ];

  meta = {
    description = "Modern, asynchronous Python client for the Bandcamp API";
    homepage = "https://github.com/ALERTua/bandcamp_async_api";
    # https://github.com/ALERTua/bandcamp_async_api/issues/34
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
