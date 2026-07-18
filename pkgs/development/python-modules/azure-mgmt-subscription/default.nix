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
  pname = "azure-mgmt-subscription";
  version = "3.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-TiVbTOm5JDV7uMUAmzyIogFNMgOySV4iVvoCe/hOgA4=";
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
  pythonImportsCheck = [ "azure.mgmt.subscription" ];

  meta = {
    description = "This is the Microsoft Azure Subscription Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
