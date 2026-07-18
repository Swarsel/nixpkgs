{
  lib,
  azure-ai-agents,
  azure-cli,
  azure-core,
  azure-storage-blob,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "azure-ai-projects";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tfAwJMzw/VQ/vg9avMdORbFezMHHGrh/xxxjBh2f1jw=";
    pname = "azure_ai_projects";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    azure-core
    azure-storage-blob
    azure-ai-agents
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.ai.projects"
  ];

  meta = {
    description = "Microsoft Azure AI Projects Client Library for Python";
    homepage = "https://pypi.org/project/azure-ai-projects/#history";
    license = lib.licenses.mit;
    maintainers = azure-cli.meta.maintainers;
  };
}
