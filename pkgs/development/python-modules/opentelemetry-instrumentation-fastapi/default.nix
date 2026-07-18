{
  buildPythonPackage,
  fastapi,
  hatchling,
  httpx,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-asgi,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytestCheckHook,
  requests,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-fastapi";

  nativeCheckInputs = [
    httpx
    opentelemetry-test-utils
    pytestCheckHook
    requests
  ];

  build-system = [ hatchling ];

  dependencies = [
    fastapi
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-instrumentation-asgi
    opentelemetry-semantic-conventions
    opentelemetry-util-http
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.fastapi" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-fastapi";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Instrumentation for fastapi";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-fastapi";
  };
}
