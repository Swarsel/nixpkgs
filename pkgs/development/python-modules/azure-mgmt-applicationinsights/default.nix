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
  pname = "azure-mgmt-applicationinsights";
  version = "4.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FVMTkPEs49dnzT8ZSa82qjkHfBRclS/sTYAwPIbse2w=";
    pname = "azure_mgmt_applicationinsights";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Application Insights Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/applicationinsights/azure-mgmt-applicationinsights";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-applicationinsights_${version}/sdk/applicationinsights/azure-mgmt-applicationinsights/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
