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
  pname = "azure-mgmt-iothubprovisioningservices";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-04OoJuff93L62G6IozpmHpEaUbHHHD6nKlkMHVoJvJ4=";
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
  pythonImportsCheck = [ "azure.mgmt.iothubprovisioningservices" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure IoTHub Provisioning Services Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      maxwilson
    ];
  };
})
