{
  lib,
  azure-cli,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "azure-ai-agents";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-651yJigtAyBsP6s/PuCi/HHgrTjlLS9PGaksVu2VGuo=";
    pname = "azure_ai_agents";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.ai.agents"
  ];

  meta = {
    description = "Microsoft Corporation Azure AI Agents Client Library for Python";
    homepage = "https://pypi.org/project/azure-ai-agents";
    license = lib.licenses.mit;
    maintainers = azure-cli.meta.maintainers;
  };
}
