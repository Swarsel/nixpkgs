{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  llm,
  llm-ollama,
  ollama,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-ollama";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "taketwo";
    repo = "llm-ollama";
    tag = version;
    hash = "sha256-PoFn/nl7CU9I3ssBMpkUMp0akQxQDz1bbht9ko+Tpc0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-mock
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    llm
    ollama
    pydantic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "llm_ollama"
  ];

  passthru.tests = llm.mkPluginTest llm-ollama;

  meta = {
    description = "LLM plugin providing access to Ollama models using HTTP API";
    homepage = "https://github.com/taketwo/llm-ollama";
    changelog = "https://github.com/taketwo/llm-ollama/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ erethon ];
  };
}
