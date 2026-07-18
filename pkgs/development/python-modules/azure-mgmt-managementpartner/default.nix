{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-managementpartner";
  version = "1.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-HNWRhIRUoRXCFtIWo/t4AsG13gSxBeJpbkI3sPh2jy8=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrestazure
    azure-common
    azure-mgmt-core
    azure-mgmt-nspkg
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.managementpartner" ];

  meta = {
    description = "This is the Microsoft Azure ManagementPartner Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
