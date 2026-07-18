{
  lib,
  azure-mgmt-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-storage";
  version = "24.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-p/cGgWOzCOXx9xhUGsgBT3/5IZ2gRjv3NG7inZw0mTg=";
    pname = "azure_mgmt_storage";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-mgmt-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.storage" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Storage Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-storage_${version}/sdk/storage/azure-mgmt-storage/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
}
