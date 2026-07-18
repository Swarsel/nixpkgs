{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-genai,
  hatchling,
  llama-index-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-embeddings-google-genai";
  version = "0.5.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-xA0J65uYGUnbWaNh0yJ0U8IumOnhjTXHK9Jklnvd2UQ=";
    pname = "llama_index_embeddings_google_genai";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    google-genai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.embeddings.google_genai" ];

  meta = {
    description = "LlamaIndex Embeddings Integration for Google GenAI";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/embeddings/llama-index-embeddings-google-genai";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
