{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-test-utils,
  pytest-benchmark,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-logging";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
  ];

  pyproject = true;

  pytestFlags = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [ "opentelemetry.instrumentation.logging" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-logging";

  meta = opentelemetry-instrumentation.meta // {
    description = "Logging instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-logging";
  };
}
