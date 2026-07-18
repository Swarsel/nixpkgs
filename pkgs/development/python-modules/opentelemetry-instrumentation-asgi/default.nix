{
  asgiref,
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
  pname = "opentelemetry-instrumentation-asgi";
  # Tests have issues starting with 0.47b0
  doCheck = false;

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    asgiref
    opentelemetry-instrumentation
    opentelemetry-api
    opentelemetry-semantic-conventions
    opentelemetry-util-http
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.asgi" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-asgi";

  meta = opentelemetry-instrumentation.meta // {
    description = "ASGI instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-asgi";
  };
}
