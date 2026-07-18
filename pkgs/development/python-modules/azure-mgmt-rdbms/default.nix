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
  pname = "azure-mgmt-rdbms";
  version = "10.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-qH1AHIdshHNM3UiIr1UeShRhtLMo2YFq9gy4rFl58DU=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    msrest
    msrestazure
  ]
  ++ lib.optionals (!isPy3k) [ azure-mgmt-nspkg ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.rdbms" ];

  meta = {
    description = "This is the Microsoft Azure RDBMS Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
