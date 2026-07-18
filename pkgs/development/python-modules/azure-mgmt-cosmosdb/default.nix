{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  msrest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-cosmosdb";
  version = "9.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Rni/BCvcIIqiT8pxdnrCm28qJyKseHJgg3Glki87bDc=";
    pname = "azure_mgmt_cosmosdb";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.cosmosdb" ];

  meta = {
    description = "Module to work with the Microsoft Azure Cosmos DB Management";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-cosmosdb_${version}/sdk/cosmos/azure-mgmt-cosmosdb/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
