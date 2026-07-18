{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-generativeai,
  hatchling,
  llama-index-core,
}:

buildPythonPackage rec {
  pname = "llama-index-vector-stores-google";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lf1Wr8l6azfxrokcGilR+IriU465LmFXDiqfHrCdrO0=";
    pname = "llama_index_vector_stores_google";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    google-generativeai
    llama-index-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.vector_stores.google" ];
  pythonRelaxDeps = [ "google-generativeai" ];

  meta = {
    description = "LlamaIndex Vector Store Integration for Google";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/vector_stores/llama-index-vector-stores-google";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
