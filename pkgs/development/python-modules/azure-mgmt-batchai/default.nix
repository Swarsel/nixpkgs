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
  pname = "azure-mgmt-batchai";
  version = "7.0.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-XfAE/QyST8ZVlJR6nP9Pdgh97hfIhFM6G7sLINsn06M=";
    pname = "azure_mgmt_batchai";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    isodate
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Batch AI Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-batchai_${finalAttrs.version}/sdk/batchai/azure-mgmt-batchai/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
