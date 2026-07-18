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
  pname = "azure-mgmt-databricks";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cNETYtwtF/X7HbDP5lwa9VuPE28aDbmltR56z3YM9bk=";
    extension = "zip";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    isodate
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;

  meta = {
    description = "Microsoft Azure Data Bricks Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/databricks/azure-mgmt-databricks";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-databricks_${version}/sdk/databricks/azure-mgmt-databricks/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
