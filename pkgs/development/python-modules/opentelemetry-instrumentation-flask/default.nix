{
  buildPythonPackage,
  flask,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-wsgi,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  packaging,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-flask";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    flask
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-instrumentation-wsgi
    opentelemetry-semantic-conventions
    opentelemetry-util-http
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.flask" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-flask";

  meta = opentelemetry-instrumentation.meta // {
    description = "Flask Middleware for OpenTelemetry based on the WSGI middleware";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-flask";
  };
}
