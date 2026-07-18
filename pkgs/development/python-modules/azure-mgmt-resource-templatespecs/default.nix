{
  lib,
  azure-cli,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-resource-templatespecs";
  version = "1.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-D55zmrQ9sq2HDq5d8bXEv6BQC76hxuWKpeLpw4X6y8U=";
    pname = "azure_mgmt_resource_templatespecs";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.mgmt.resource.templatespecs"
  ];

  pythonNamespaces = [
    "azure.mgmt"
    "azure.mgmt.resource"
  ];

  meta = {
    description = "Microsoft Azure SDK for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/resources/azure-mgmt-resource-templatespecs";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-resource-templatespecs_${version}/sdk/resources/azure-mgmt-resource-templatespecs/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = azure-cli.meta.maintainers;
  };
}
