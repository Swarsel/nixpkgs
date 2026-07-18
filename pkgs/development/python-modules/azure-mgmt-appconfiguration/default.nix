{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-appconfiguration";
  version = "6.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zBaEyScWadchaKV5fhg1EmVWa/oSPre/gY3h1vNa5d4=";
    pname = "azure_mgmt_appconfiguration";
  };

  # no tests included
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.common"
    "azure.mgmt.appconfiguration"
  ];

  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "Microsoft Azure App Configuration Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/appconfiguration/azure-mgmt-appconfiguration";
    changelog = "https://github.com/Azure/azure-sdk-for-python/tree/azure-mgmt-appconfiguration_${version}/sdk/appconfiguration/azure-mgmt-appconfiguration/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
