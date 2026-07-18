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
  pname = "azure-mgmt-datafactory";
  version = "9.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9f3VzUFvDtcd/t8F3HZ3uPDlLzQo/VsXsEySAN2NNrM=";
    pname = "azure_mgmt_datafactory";
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
  pythonImportsCheck = [ "azure.mgmt.datafactory" ];

  meta = {
    description = "This is the Microsoft Azure Data Factory Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/tree/azure-mgmt-datafactory_${version}/sdk/datafactory/azure-mgmt-datafactory";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
