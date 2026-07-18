{
  lib,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-servicemanagement-legacy";
  version = "0.20.8";

  src = fetchPypi {
    inherit version;
    hash = "sha256-42neKpeBjx26GTIzeBTyjTmj5tcNklNQoaBoEDjC+Xc=";
    pname = "azure_servicemanagement_legacy";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.servicemanagement" ];
  pythonNamespaces = [ "azure" ];

  meta = {
    description = "This is the Microsoft Azure Service Management Legacy Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/core/azure-servicemanagement-legacy";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-servicemanagement-legacy_${version}/sdk/core/azure-servicemanagement-legacy/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
}
