{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
}:

buildPythonPackage rec {
  pname = "llama-index-readers-database";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LDxPRKd+i4zwGArLW8b8URtBc9Y+id/uKEybnsW4c5U=";
    pname = "llama_index_readers_database";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ llama-index-core ];
  pyproject = true;
  pythonImportsCheck = [ "llama_index.readers.database" ];

  meta = {
    description = "LlamaIndex Readers Integration for Databases";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/readers/llama-index-readers-database";
    changelog = "https://github.com/run-llama/llama_index/blob/main/llama-index-integrations/readers/llama-index-readers-database/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
