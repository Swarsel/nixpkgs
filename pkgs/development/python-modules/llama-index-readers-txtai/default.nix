{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-txtai";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-dZg+EqXQvqaMN4DQS3VPZi3Ak5j1Y+KZ6ngsJkK5SYA=";
    pname = "llama_index_readers_txtai";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ llama-index-core ];
  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.txtai" ];

  meta = {
    description = "LlamaIndex Readers Integration for txtai";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-txtai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
