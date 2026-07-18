{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-aiohttp";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "pytest-aiohttp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SYMwVmcgPLOasW6TQGqqNO+sbp8zQQtDHb3IyAVO6KI=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    pytest-asyncio
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
    "-Wignore::pytest.PytestDeprecationWarning"
  ];

  meta = {
    description = "Pytest plugin for aiohttp support";
    homepage = "https://github.com/aio-libs/pytest-aiohttp/";
    changelog = "https://github.com/aio-libs/pytest-aiohttp/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
