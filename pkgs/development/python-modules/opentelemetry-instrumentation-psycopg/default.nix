{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-dbapi,
  opentelemetry-test-utils,
  psycopg,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-psycopg";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    psycopg
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-instrumentation-dbapi
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.psycopg" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-psycopg";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Psycopg Instrumentation";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-psycopg";
  };
}
