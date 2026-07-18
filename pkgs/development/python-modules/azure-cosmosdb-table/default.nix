{
  lib,
  azure-common,
  azure-cosmosdb-nspkg,
  azure-storage-common,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  isPy3k,
  setuptools,
  futures ? null,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-cosmosdb-table";
  version = "1.0.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XwYdKrjc8vC06WXVl257eusSR+qJaRHw4dKQkqqqKcc=";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    azure-common
    azure-storage-common
    azure-cosmosdb-nspkg
  ]
  ++ lib.optionals (!isPy3k) [ futures ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Log Analytics Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
