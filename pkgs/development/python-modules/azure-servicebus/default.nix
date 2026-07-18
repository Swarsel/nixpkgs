{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-servicebus";
  version = "7.14.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-cKYzhFV67AvucndA57Jd7Snp5wG3dhF2RXf9dAI4lAI=";
    pname = "azure_servicebus";
  };

  # Tests require dev-tools
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.servicebus" ];

  meta = {
    description = "Microsoft Azure Service Bus Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/servicebus/azure-servicebus";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-servicebus_${version}/sdk/servicebus/azure-servicebus/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
