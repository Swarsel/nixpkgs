{
  lib,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-servicefabric";
  version = "8.2.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-9JyHWUR5cIF7my09S5dDl2Xc91ugG2Bmzpa2BQUvuyM=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.servicefabric" ];

  meta = {
    description = "This project provides a client library in Python that makes it easy to consume Microsoft Azure Storage services";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
