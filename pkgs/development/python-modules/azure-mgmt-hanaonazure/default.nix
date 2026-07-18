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
  pname = "azure-mgmt-hanaonazure";
  version = "1.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-8vg0L7/e2L5BZfsNbwELaN8HSIaBHbPiyaULNg7i3To=";
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
  pythonImportsCheck = [ "azure.mgmt.hanaonazure" ];

  meta = {
    description = "This is the Microsoft Azure SAP Hana on Azure Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
