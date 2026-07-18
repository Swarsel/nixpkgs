{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-servicelinker";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-QVw6Y9HachwBRwCbF0cSGLCAkSJtNnXBvsj5YX1TmJU=";
    extension = "zip";
  };

  # no tests with sdist
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.servicelinker" ];

  meta = {
    description = "Microsoft Azure Servicelinker Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
