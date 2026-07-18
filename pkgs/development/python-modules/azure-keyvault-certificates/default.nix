{
  lib,
  azure-common,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-keyvault-certificates";
  version = "4.11.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-c02aZfqg8r1FueFi0xesrexxBWk06/S7/gWLI9dL0HM=";
    pname = "azure_keyvault_certificates";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    azure-common
    azure-core
    isodate
    typing-extensions
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "azure.keyvault.certificates" ];
  pythonNamespaces = [ "azure.keyvault" ];

  meta = {
    description = "Microsoft Azure Key Vault Certificates Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/keyvault/azure-keyvault-certificates";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-keyvault-certificates_${version}/sdk/keyvault/azure-keyvault-certificates/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
