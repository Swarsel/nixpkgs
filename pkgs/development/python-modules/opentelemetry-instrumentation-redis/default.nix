{
  buildPythonPackage,
  fakeredis,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  pytestCheckHook,
  redis,
  wrapt,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-redis";

  nativeCheckInputs = [
    fakeredis
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    wrapt
  ];

  optional-dependencies = {
    instruments = [ redis ];
  };

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.redis" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-redis";

  meta = opentelemetry-instrumentation.meta // {
    description = "Redis instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-redis";
  };
}
