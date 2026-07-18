{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-maps";
  version = "2.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XVaml4UuVBanYYHxjB1YT/PvExzgAPbD4gI3Hbc0dI0=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    isodate
    azure-common
    azure-mgmt-core
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.maps" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Maps Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/v${finalAttrs.version}/sdk/maps/azure-mgmt-maps/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
