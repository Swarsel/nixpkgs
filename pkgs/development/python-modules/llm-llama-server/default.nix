{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-llama-server,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-llama-server";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-llama-server";
    tag = version;
    hash = "sha256-jtFSfGu3JhNUfTsspY+OFLTMt9jQrh6R05sK9KBOKTE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_llama_server" ];
  passthru.tests = llm.mkPluginTest llm-llama-server;

  meta = {
    description = "LLM plugin for interacting with llama-server models";
    homepage = "https://github.com/simonw/llm-llama-server";
    changelog = "https://github.com/simonw/llm-llama-server/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
