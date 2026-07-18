{
  lib,
  buildPythonPackage,
  fetchPypi,
  grpcio,
  hatchling,
  llama-index-core,
  qdrant-client,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-vector-stores-qdrant";
  version = "0.10.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-MSK2RJAce1jmFv2eftT9HsJgTGPxuFxdatRIIK8ym+I=";
    pname = "llama_index_vector_stores_qdrant";
  };

  build-system = [ hatchling ];

  dependencies = [
    grpcio
    llama-index-core
    qdrant-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.vector_stores.qdrant" ];

  meta = {
    description = "LlamaIndex Vector Store Integration for Qdrant";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/vector_stores/llama-index-vector-stores-qdrant";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
