{
  lib,
  fetchFromGitHub,
  azure-core,
  buildPythonPackage,
  gitUpdater,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-eventhub";
  version = "39.0.0";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-python";
    tag = "azure-mgmt-containerservice_${version}";
    hash = "sha256-zufXc8LR4STHi/jjV0bcLsifcHIif2m+3Q/KZlsSkRw=";
  };

  # too complicated to set up
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.eventhub"
    "azure.eventhub.aio"
  ];

  sourceRoot = "${src.name}/sdk/eventhub/azure-eventhub";

  passthru = {
    updateScript = gitUpdater { rev-prefix = "azure.eventhub."; };
  };

  meta = {
    description = "Microsoft Azure Event Hubs Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/master/sdk/eventhub/azure-eventhub";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/${src.tag}/sdk/eventhub/azure-eventhub/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
