{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-containerregistry";
  version = "15.1.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-h7sN4yuZ4aSTqlLUz083PvDaFoHdjmmhH4dhvpNAkLE=";
    pname = "azure_mgmt_containerregistry";
  };

  # no tests included
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
    "azure.common"
    "azure.mgmt.containerregistry"
  ];

  meta = {
    description = "Microsoft Azure Container Registry Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/containerregistry/azure-mgmt-containerregistry";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-containerregistry_${version}/sdk/containerregistry/azure-mgmt-containerregistry/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
