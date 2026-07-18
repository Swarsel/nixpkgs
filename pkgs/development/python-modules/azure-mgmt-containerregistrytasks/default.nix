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
  pname = "azure-mgmt-containerregistrytasks";
  version = "1.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-1nMN1cm/yp/fD+D5M3BtPH+4VcoQxWhQZQsHDpxsr1E=";
    pname = "azure_mgmt_containerregistrytasks";
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
    "azure.mgmt.containerregistrytasks"
  ];

  meta = {
    description = "Microsoft Azure Container Registry Tasks Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/containerregistry/azure-mgmt-containerregistrytasks";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
