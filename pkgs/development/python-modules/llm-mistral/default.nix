{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  httpx-sse,
  llm,
  llm-mistral,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-mistral";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-mistral";
    tag = version;
    hash = "sha256-4ajvsq0sm3/vdiHUuNxHsHKdX58VNNpHIwhWI0ws+08=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-httpx
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    httpx
    httpx-sse
    llm
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_mistral" ];
  passthru.tests = llm.mkPluginTest llm-mistral;

  meta = {
    description = "LLM plugin providing access to Mistral models using the Mistral API";
    homepage = "https://github.com/simonw/llm-mistral";
    changelog = "https://github.com/simonw/llm-mistral/releases/tag/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
