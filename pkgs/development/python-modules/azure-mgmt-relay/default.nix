{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-relay";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "c93b7550e64b6734bf23ce57ca974a3ea929b734c58d1fe3669728c4fd2d2eb3";
    extension = "zip";
  };

  preBuild = ''
    rm -f azure_bdist_wheel.py
  '';

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.relay" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Relay Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
