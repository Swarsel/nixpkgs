{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-msi";
  version = "7.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GgGgifH2bLDUsohmA9W6QV82Dv8L5vaFc37N1Zx4Ils=";
    pname = "azure_mgmt_msi";
  };

  propagatedBuildInputs = [
    msrest
    azure-common
    azure-mgmt-core
  ];

  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "azure.mgmt.msi" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure MSI Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/resources/azure-mgmt-msi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
