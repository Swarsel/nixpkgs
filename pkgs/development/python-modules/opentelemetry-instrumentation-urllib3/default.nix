{
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  httpretty,
  # dependencies
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  opentelemetry-util-http,
  pytestCheckHook,
  respx,
  # optional-dependencies
  urllib3,
  wrapt,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-urllib3";

  nativeCheckInputs = [
    httpretty
    opentelemetry-test-utils
    pytestCheckHook
    respx
    urllib3
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    wrapt
    opentelemetry-util-http
  ];

  optional-dependencies = {
    instruments = [
      urllib3
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.urllib3" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-urllib3";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry urllib3 instrumentation";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-urllib3";
  };
}
