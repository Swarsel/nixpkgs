{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-datamigration";
  version = "10.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-wo748WK5RaTLUAZASjA3QcJG8DMSSeYB0V6h/c6VxUo=";
    pname = "azure_mgmt_datamigration";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Data Migration Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/datamigration/azure-mgmt-datamigration";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
