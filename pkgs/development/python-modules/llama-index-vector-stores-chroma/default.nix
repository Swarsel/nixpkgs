{
  lib,
  buildPythonPackage,
  chromadb,
  fetchPypi,
  hatchling,
  llama-index-core,
}:

buildPythonPackage rec {
  pname = "llama-index-vector-stores-chroma";
  version = "0.5.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-gjhlBpvOpNnekVECca4DzW6o6wEGpbXqQ//OwD7Cpwg=";
    pname = "llama_index_vector_stores_chroma";
  };

  build-system = [ hatchling ];

  dependencies = [
    chromadb
    llama-index-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.vector_stores.chroma" ];

  meta = {
    description = "LlamaIndex Vector Store Integration for Chroma";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/vector_stores/llama-index-vector-stores-chroma";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
