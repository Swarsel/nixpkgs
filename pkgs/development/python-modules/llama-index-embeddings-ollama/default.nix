{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  ollama,
  pytest-asyncio,
}:

buildPythonPackage rec {
  pname = "llama-index-embeddings-ollama";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GdLSoOPwk0SA6uMSQ6xfHOFxMZV4ucCtrSXPG2w1ZZ4=";
    pname = "llama_index_embeddings_ollama";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    ollama
    pytest-asyncio
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.embeddings.ollama" ];
  pythonRelaxDeps = [ "ollama" ];

  meta = {
    description = "LlamaIndex Llms Integration for Ollama";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/embeddings/llama-index-embeddings-ollama";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
