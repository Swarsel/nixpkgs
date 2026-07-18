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
  pname = "azure-mgmt-reservations";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BHCFEFst5jfyIEo0hm86belpxW7EygZCBJ8PTqzqHKc=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Reservations Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
