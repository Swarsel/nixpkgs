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
  pname = "azure-monitor-ingestion";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-l6/ueA2a4waRKM3ncCfUzGL6gk/mTVusiArEpksKDE4=";
    pname = "azure_monitor_ingestion";
  };

  # requires checkout from mono-repo and a mock account
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.monitor.ingestion"
    "azure.monitor.ingestion.aio"
  ];

  meta = {
    description = "Send custom logs to Azure Monitor using the Logs Ingestion API";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/monitor/azure-monitor-ingestion";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-monitor-ingestion_${version}/sdk/monitor/azure-monitor-ingestion/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
