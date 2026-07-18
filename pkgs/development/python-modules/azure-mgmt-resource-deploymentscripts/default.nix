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
  pname = "azure-mgmt-resource-deploymentscripts";
  version = "1.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Vm2FWVPpSbsrNMtD4ecwVKqnkoHHRhO3Rf/duCyAI3U=";
    pname = "azure_mgmt_resource_deploymentscripts";
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
    "azure.mgmt.resource.deploymentscripts"
  ];

  pythonNamespaces = [
    "azure.mgmt"
    "azure.mgmt.resource"
  ];

  meta = {
    description = "Microsoft Azure SDK for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/resources/azure-mgmt-resource-deploymentscripts";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-resource-deploymentscripts_${version}/sdk/resources/azure-mgmt-resource-deploymentscripts/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = azure-cli.meta.maintainers;
  };
}
