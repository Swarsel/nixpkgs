{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  httpx,
  pillow,
  pydantic,
  pytest-asyncio,
  pytest-httpserver,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ollama";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "ollama";
    repo = "ollama-python";
    tag = "v${version}";
    hash = "sha256-kPFimI9h8BL3qQ+puZy70AYnX3zpbZ2nV5revmYPjIY=";
  };

  nativeCheckInputs = [
    pillow
    pytest-asyncio
    pytest-httpserver
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    httpx
    pydantic
  ];

  disabledTestPaths = [
    # Don't test the examples
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ollama" ];
  pythonRelaxDeps = [ "httpx" ];

  meta = {
    description = "Ollama Python library";
    homepage = "https://github.com/ollama/ollama-python";
    changelog = "https://github.com/ollama/ollama-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
