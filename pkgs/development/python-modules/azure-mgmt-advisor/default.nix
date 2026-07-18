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

buildPythonPackage rec {
  pname = "azure-mgmt-advisor";
  version = "9.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/ECLNzFf6EeBtRkST4yxuKwQsvQkHkOdDT4l/WyhjXs=";
    extension = "zip";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Advisor Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
