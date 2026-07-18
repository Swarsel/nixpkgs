{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-netapp";
  version = "16.0.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-/tcO1+pIMcB2e+T1f2ClHxLjSzqv0PherTPMgI12/BY=";
    pname = "azure_mgmt_netapp";
  };

  # no tests included
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.common"
    "azure.mgmt.netapp"
  ];

  meta = {
    description = "Microsoft Azure NetApp Files Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-netapp_${finalAttrs.version}/sdk/netapp/azure-mgmt-netapp/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
