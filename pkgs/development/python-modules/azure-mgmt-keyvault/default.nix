{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-keyvault";
  version = "14.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0UGoCErkx8W9HK/spJqPP768WNxbxSkPMi6nPYswfvc=";
    pname = "azure_mgmt_keyvault";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.keyvault" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Key Vault Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-keyvault_${version}/sdk/keyvault/azure-mgmt-keyvault/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
