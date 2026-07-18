{
  lib,
  buildPythonPackage,
  hatchling,
  httpx,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytestCheckHook,
  pythonOlder,
  respx,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-httpx";
  doCheck = pythonOlder "3.14";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
    respx
  ];

  build-system = [ hatchling ];

  dependencies = [
    httpx
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    opentelemetry-util-http
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.httpx" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-httpx";

  meta = opentelemetry-instrumentation.meta // {
    description = "Allows tracing HTTP requests made by the httpx library";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-httpx";
  };
}
