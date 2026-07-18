{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
  yarl,
}:

buildPythonPackage rec {
  pname = "azure-data-tables";
  version = "12.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-sU/JSjIjooNf9WiOF9jhB7J8fNfEEUE48qyBNzcjcF0=";
    pname = "azure_data_tables";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.data.tables" ];

  meta = {
    description = "NoSQL data storage service that can be accessed from anywhere";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-data-tables_${version}/sdk/tables/azure-data-tables/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
