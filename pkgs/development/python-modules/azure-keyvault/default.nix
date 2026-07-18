{
  lib,
  azure-keyvault-certificates,
  azure-keyvault-keys,
  azure-keyvault-secrets,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-keyvault";
  version = "4.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-cxrdEIo+KatP1QGjxHclbChsNNCZazg/tqOUVGKTN2E=";
    extension = "zip";
  };

  # this is just a meta package, which contains keys and secrets packages
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-keyvault-certificates
    azure-keyvault-keys
    azure-keyvault-secrets
  ];

  doBuild = false;
  pyproject = true;

  pythonImportsCheck = [
    "azure.keyvault.keys"
    "azure.keyvault.secrets"
  ];

  meta = {
    description = "This is the Microsoft Azure Key Vault Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
