{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-dbapi,
  opentelemetry-test-utils,
  psycopg2,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-psycopg2";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    psycopg2
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-instrumentation-dbapi
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.psycopg2" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-psycopg2";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Psycopg Instrumentation";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-psycopg2";
  };
}
