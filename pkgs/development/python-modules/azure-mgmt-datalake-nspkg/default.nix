{
  lib,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-datalake-nspkg";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-3rGSukIviz7Ccs5OiHNnlvIW8o6lsD8oMx14S3o/SIA=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ azure-mgmt-nspkg ];
  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Data Lake Management namespace package";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
