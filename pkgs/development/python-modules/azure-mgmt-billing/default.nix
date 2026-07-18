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

buildPythonPackage rec {
  pname = "azure-mgmt-billing";
  version = "7.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jgplxlEQtTpCk35b7WrgDvydYgaXLZa/1KdOgMhcLXs=";
    pname = "azure_mgmt_billing";
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
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Billing Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/billing/azure-mgmt-billing";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-billing_${version}/sdk/billing/azure-mgmt-billing/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
