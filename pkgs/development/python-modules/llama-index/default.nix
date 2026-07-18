{
  buildPythonPackage,
  hatchling,
  llama-index-cli,
  llama-index-core,
  llama-index-embeddings-openai,
  llama-index-llms-openai,
  nltk,
}:

buildPythonPackage {
  inherit (llama-index-core) version src meta;
  pname = "llama-index";
  build-system = [ hatchling ];

  dependencies = [
    llama-index-cli
    llama-index-core
    llama-index-embeddings-openai
    llama-index-llms-openai
    nltk
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index" ];
  pythonRelaxDeps = [ "llama-index-core" ];
}
