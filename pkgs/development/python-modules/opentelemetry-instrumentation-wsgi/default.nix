{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-wsgi";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-instrumentation
    opentelemetry-api
    opentelemetry-semantic-conventions
    opentelemetry-util-http
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.wsgi" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-wsgi";

  meta = opentelemetry-instrumentation.meta // {
    description = "WSGI Middleware for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-wsgi";
  };
}
