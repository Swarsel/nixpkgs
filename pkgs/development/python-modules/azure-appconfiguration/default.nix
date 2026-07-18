{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-appconfiguration";
  version = "1.7.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zv11spi4mKjtn3MEjz859OgQWaWM2DLQUjeH/B2RKgY=";
    pname = "azure_appconfiguration";
  };

  # Tests are not shipped
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.appconfiguration" ];

  meta = {
    description = "Microsoft App Configuration Data Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/master/sdk/appconfiguration/azure-appconfiguration";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-appconfiguration_${version}/sdk/appconfiguration/azure-appconfiguration/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
