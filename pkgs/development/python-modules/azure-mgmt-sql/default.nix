{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-sql";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-EpBCzAESJeJ67m7yaX1YX6VyLl0a6wA4r2rSRRooVFc=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ]
  ++ lib.optionals (!isPy3k) [ azure-mgmt-nspkg ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.sql" ];

  meta = {
    description = "This is the Microsoft Azure SQL Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
