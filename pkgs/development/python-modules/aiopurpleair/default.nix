{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certifi,
  poetry-core,
  pydantic,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiopurpleair";
  version = "2025.08.1";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "aiopurpleair";
    tag = version;
    hash = "sha256-VmKIIgfZFk9z8WORDHA4ibL4FZchiRrT6L0rCkxosoc=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pydantic
    certifi
  ];

  disabledTestPaths = [
    # Ignore the examples directory as the files are prefixed with test_.
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiopurpleair" ];

  meta = {
    description = "Python library for interacting with the PurpleAir API";
    homepage = "https://github.com/bachya/aiopurpleair";
    changelog = "https://github.com/bachya/aiopurpleair/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
