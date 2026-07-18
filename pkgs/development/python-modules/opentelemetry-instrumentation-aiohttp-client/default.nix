{
  aiohttp,
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytestCheckHook,
  wrapt,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-aiohttp-client";
  # missing https://github.com/ezequielramos/http-server-mock
  # which looks unmaintained
  doCheck = false;

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    opentelemetry-util-http
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.aiohttp_client" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-aiohttp-client";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Instrumentation for aiohttp-client";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-aiohttp-client";
  };
}
