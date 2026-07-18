{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-cosmos";
  version = "4.14.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MjmmBf4pyUt3ORgmdzqj0Nm75Lk5A/zltkNLDzJ0K6c=";
    pname = "azure_cosmos";
  };

  # Requires an active Azure Cosmos service
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.cosmos" ];
  pythonNamespaces = [ "azure" ];

  meta = {
    description = "Azure Cosmos DB API";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/cosmos/azure-cosmos";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-cosmos_${version}/sdk/cosmos/azure-cosmos/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
