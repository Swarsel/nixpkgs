{
  lib,
  azure-common,
  azure-mgmt-datalake-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-datalake-analytics";
  version = "0.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-DWTEaJpn1hOOuf+6/y7aK6zn0wuEZAFnMYPctCcU3o8=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrestazure
    azure-common
    azure-mgmt-datalake-nspkg
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.datalake.analytics" ];
  pythonNamespaces = [ "azure.mgmt.datalake" ];

  meta = {
    description = "This is the Microsoft Azure Data Lake Analytics Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
