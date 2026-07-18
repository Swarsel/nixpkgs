{
  lib,
  azure-common,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-synapse-managedprivateendpoints";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kA6urM/9zQEBKySKfQSQCMkoB7dJ7dHJB0ypJIVUwX4=";
    extension = "zip";
  };

  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-core
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.synapse.managedprivateendpoints" ];
  pythonNamespaces = [ "azure.synapse" ];

  meta = {
    description = "Microsoft Azure Synapse Managed Private Endpoints Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/synapse/azure-synapse-managedprivateendpoints";
    changelog = "https://github.com/Azure/azure-sdk-for-python/tree/azure-synapse-managedprivateendpoints_${version}/sdk/synapse/azure-synapse-managedprivateendpoints";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
