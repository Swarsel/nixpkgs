{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  sentence-transformers,
}:

buildPythonPackage rec {
  pname = "llama-index-embeddings-huggingface";
  version = "0.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2ooqZd+UBBEsRDDfraCdT4RroWUZeiXb539zQBTFaoc=";
    pname = "llama_index_embeddings_huggingface";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    sentence-transformers
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.embeddings.huggingface" ];

  meta = {
    description = "LlamaIndex Embeddings Integration for Huggingface";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/embeddings/llama-index-embeddings-huggingface";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
