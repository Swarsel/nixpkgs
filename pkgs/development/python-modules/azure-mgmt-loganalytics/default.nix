{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-loganalytics";
  version = "12.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2hKKfgKRvn+iBjhI35KpGAz1wW1CrcCdK8Lv1xFTa/s=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.loganalytics" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Log Analytics Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
