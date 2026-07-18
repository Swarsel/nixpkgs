{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-notificationhubs";
  version = "8.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Tdkk9HBJk+Pr8dQuK+HL4LDZCOaVhX+gjENprhHQ6zY=";
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
    azure-mgmt-nspkg
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.notificationhubs" ];

  meta = {
    description = "This is the Microsoft Azure Notification Hubs Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
