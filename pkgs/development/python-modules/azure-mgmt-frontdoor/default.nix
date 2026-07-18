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
  pname = "azure-mgmt-frontdoor";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DSV/vIE6r0wgPLpHfT4ODqNoxzeCPIlAksmsnEuExSg=";
    pname = "azure_mgmt_frontdoor";
  };

  # Tests are only available in mono repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.frontdoor" ];

  meta = {
    description = "Microsoft Azure Front Door Service Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/network/azure-mgmt-frontdoor";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-frontdoor_${version}/sdk/network/azure-mgmt-frontdoor/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
