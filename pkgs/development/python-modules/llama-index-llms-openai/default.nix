{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  llama-index-core,
  openai,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-llms-openai";
  version = "0.7.9";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9UoktxcTTIbnJABwV6BqhDlPAZ0fAekYtiSJTiCKht8=";
    pname = "llama_index_llms_openai";
  };

  # Tests are only available in the mono repo
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    llama-index-core
    openai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index.llms.openai" ];

  meta = {
    description = "LlamaIndex LLMS Integration for OpenAI";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/llms/llama-index-llms-openai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
