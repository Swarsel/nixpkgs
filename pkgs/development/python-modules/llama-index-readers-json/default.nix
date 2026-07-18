{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-readers-json";
  version = "0.5.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-315Uzbm3CuRJQpAwnrLxQ6zr0e1pCmM3JKMV6KhrEs8=";
    pname = "llama_index_readers_json";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ llama-index-core ];
  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.json" ];

  meta = {
    description = "LlamaIndex Readers Integration for Json";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-json";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
