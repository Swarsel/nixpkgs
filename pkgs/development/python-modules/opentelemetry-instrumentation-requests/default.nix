{
  buildPythonPackage,
  hatchling,
  httpretty,
  mocket,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytest-benchmark,
  pytestCheckHook,
  requests,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-requests";

  nativeCheckInputs = [
    httpretty
    mocket
    opentelemetry-test-utils
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    opentelemetry-util-http
    requests
  ];

  pyproject = true;

  pytestFlags = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [ "opentelemetry.instrumentation.requests" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-requests";

  meta = opentelemetry-instrumentation.meta // {
    description = "Requests instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-requests";
  };
}
