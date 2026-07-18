{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-keyvault-administration";
  version = "4.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GSRWYnTEWWdf6qKbPojD2QspnDKMhNxcG4V85RCp7Zo=";
    pname = "azure_keyvault_administration";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    azure-core
    typing-extensions
    isodate
  ];

  # Tests require checkout from mono-repo
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "azure.keyvault.administration" ];
  pythonNamespaces = [ "azure.keyvault" ];

  meta = {
    description = "Microsoft Azure Key Vault Administration Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/master/sdk/keyvault/azure-keyvault-administration";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-keyvault-administration_${version}/sdk/keyvault/azure-keyvault-administration/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
