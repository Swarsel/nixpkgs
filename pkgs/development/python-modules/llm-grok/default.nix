{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  httpx-sse,
  llm,
  llm-grok,
  pytest-httpx,
  pytestCheckHook,
  rich,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-grok";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "Hiepler";
    repo = "llm-grok";
    tag = "v${version}";
    hash = "sha256-bvJKQZka/2Vkk66gARIwv3XwIs+gb5KNyCHNWH9doXA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-httpx
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    httpx
    httpx-sse
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_grok" ];
  passthru.tests = llm.mkPluginTest llm-grok;

  meta = {
    description = "LLM plugin providing access to Grok models using the xAI API";
    homepage = "https://github.com/Hiepler/llm-grok";
    changelog = "https://github.com/Hiepler/llm-grok/releases/tag/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
