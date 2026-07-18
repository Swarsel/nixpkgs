{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-test-utils,
  psutil,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-system-metrics";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-instrumentation
    opentelemetry-api
    psutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.system_metrics" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-system-metrics";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry System Metrics Instrumentation";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-system-metrics";
  };
}
