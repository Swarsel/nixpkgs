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
  pname = "azure-mgmt-policyinsights";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-rsmIKwVcRrWUxDjJf1Cj4YczEooRUwRpzgl6fFmaDl0=";
    pname = "azure_mgmt_policyinsights";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.policyinsights" ];

  meta = {
    description = "Microsoft Azure Policy Insights Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/policyinsights/azure-mgmt-policyinsights";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-policyinsights_${finalAttrs.version}/sdk/policyinsights/azure-mgmt-policyinsights/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
