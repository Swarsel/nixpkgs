{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-ai-documentintelligence";
  version = "1.0.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-TXWiUT8oOTZeurwODhdy9WAbOoyaceddoSRA2hO2NIQ=";
    pname = "azure_ai_documentintelligence";
  };

  # Tests are not shipped
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.ai.documentintelligence" ];

  meta = {
    description = "Azure AI Document Intelligence client library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/documentintelligence/azure-ai-documentintelligence/azure/ai/documentintelligence";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
