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
  pname = "uhooapi";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "getuhoo";
    repo = "uhooapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SsnRHG9ePbcmaGULlXIemfbLaEUo+8x+tBZam/MBWnU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    aioresponses
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "uhooapi" ];

  meta = {
    description = "Python client for uHoo APIs";
    homepage = "https://github.com/getuhoo/uhooapi";
    changelog = "https://github.com/getuhoo/uhooapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
