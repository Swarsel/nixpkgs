{
  lib,
  azure-common,
  azure-core,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-keyvault-keys";
  version = "4.11.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-8lexkXosOoiYPj9WdaZBlEnrJiMYiI1bUeHLO+15d5o=";
    pname = "azure_keyvault_keys";
  };

  # Tests require relative paths to utilities in the mono-repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-core
    cryptography
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure"
    "azure.core"
    "azure.common"
    "azure.keyvault"
    "azure.keyvault.keys"
  ];

  pythonNamespaces = [ "azure.keyvault" ];

  meta = {
    description = "Microsoft Azure Key Vault Keys Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/keyvault/azure-keyvault-keys";
    changelog = "https://github.com/Azure/azure-sdk-for-python/tree/azure-keyvault-keys_${version}/sdk/keyvault/azure-keyvault-keys";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
