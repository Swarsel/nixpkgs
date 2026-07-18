{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  fetchpatch,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-cors";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp-cors";
    tag = "v${version}";
    hash = "sha256-AbMuUeCNM8+oZj/hutG3zxHOwYN8uZlLFBeYTlu1fh4=";
  };

  patches = [
    # https://github.com/aio-libs/aiohttp-cors/pull/563
    (fetchpatch {
      hash = "sha256-BvE5qqAx83+084khkHt4zjXgR7Bu/ceqMOOh/6fe5TA=";
      name = "replace-deprecated-asyncio.iscoroutinefunction-with-its-counterpart-from-inspect.patch";
      url = "https://github.com/aio-libs/aiohttp-cors/commit/efafc0f780a494377910f2328057f83e95f8bf74.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  # interactive browser tests using selenium
  disabledTestPaths = [ "tests/integration" ];

  disabledTests = [
    # async def functions are not natively supported and have been skipped.
    "test_main"
    "test_defaults"
    "test_raises_forbidden_when_config_not_found"
    "test_raises_when_handler_not_extend"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_cors" ];

  meta = {
    description = "CORS support for aiohttp";
    homepage = "https://github.com/aio-libs/aiohttp-cors";
    changelog = "https://github.com/aio-libs/aiohttp-cors/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
