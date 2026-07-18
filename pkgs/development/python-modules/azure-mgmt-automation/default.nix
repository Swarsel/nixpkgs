{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-automation";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-A/NYbg/gllws7cp5plM4CHKuYnwm6lNlpVuqTq1aeO8=";
    pname = "azure_mgmt_automation";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.automation" ];

  meta = {
    description = "This is the Microsoft Azure Automation Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/automation/azure-mgmt-automation";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-automation_${finalAttrs.version}/sdk/automation/azure-mgmt-automation/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wfdewith ];
  };
})
