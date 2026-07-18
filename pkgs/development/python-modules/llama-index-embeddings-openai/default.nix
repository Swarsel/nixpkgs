{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  openai,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-embeddings-openai";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-6z5mBr6By4kSUHPiPJfAphGdq7SCetvRRpfCAprXPyk=";
    pname = "llama_index_embeddings_openai";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    openai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.embeddings.openai" ];

  meta = {
    description = "LlamaIndex Embeddings Integration for OpenAI";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-s3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
