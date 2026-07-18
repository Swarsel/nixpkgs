{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  llama-index-embeddings-openai,
  llama-index-readers-file,
  s3fs,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-s3";
  version = "0.6.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-cK5XmH4F0TZt6IMJvAnmEs7UWkekrrbEAIvd/CE33xw=";
    pname = "llama_index_readers_s3";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    llama-index-embeddings-openai
    llama-index-readers-file
    s3fs
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.s3" ];

  meta = {
    description = "LlamaIndex Readers Integration for S3";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-s3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
