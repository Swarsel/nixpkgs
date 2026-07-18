{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-network";
  version = "30.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-mxfCWeY0SAiqqAo0u8SxPxa8ARhd2dsTfqoK4mZkhho=";
    pname = "azure_mgmt_network";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.network" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "Microsoft Azure SDK for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/network/azure-mgmt-network";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-network_${finalAttrs.version}/sdk/network/azure-mgmt-network/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
})
