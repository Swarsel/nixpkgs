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
  pname = "azure-mgmt-resource-deploymentstacks";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-gI3N1xc36cpOfLhLxip079VFe2ptsOVgfNNshv1YLcc=";
    pname = "azure_mgmt_resource_deploymentstacks";
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
    "azure.mgmt.resource.deploymentstacks"
  ];

  pythonNamespaces = [
    "azure.mgmt"
    "azure.mgmt.resource"
  ];

  meta = {
    description = "Microsoft Azure SDK for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/resources/azure-mgmt-resource-deploymentstacks";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-resource-deploymentstacks_${version}/sdk/resources/azure-mgmt-resource-deploymentstacks/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = azure-cli.meta.maintainers;
  };
}
