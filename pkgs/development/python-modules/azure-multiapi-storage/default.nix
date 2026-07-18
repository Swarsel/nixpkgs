{
  lib,
  azure-common,
  azure-core,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  msrest,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-multiapi-storage";
  version = "1.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-iULj9O2+3dI82hms7nlgdvvNGkDkb5qhEQ/9oxTjHFU=";
    pname = "azure_multiapi_storage";
  };

  # no tests included
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-core
    cryptography
    msrest
    requests
    python-dateutil
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.multiapi.storagev2"
  ];

  # fix namespace
  pythonNamespaces = [ "azure.multiapi" ];

  meta = {
    description = "Microsoft Azure Storage Client Library for Python with multi API version support";
    homepage = "https://github.com/Azure/azure-multiapi-storage-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
