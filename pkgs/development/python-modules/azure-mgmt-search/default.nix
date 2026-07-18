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
  pname = "azure-mgmt-search";
  version = "9.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-oNoOwzLR9D0PastjuM/YAIWwdeka/PgS+MdprZ/crYQ=";
    pname = "azure_mgmt_search";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.search" ];

  meta = {
    description = "This is the Microsoft Azure Search Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-search_${version}/sdk/search/azure-mgmt-search/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
