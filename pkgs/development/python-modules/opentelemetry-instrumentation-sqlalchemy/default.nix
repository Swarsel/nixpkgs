{
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  # tests
  opentelemetry-test-utils,
  packaging,
  pytestCheckHook,
  sqlalchemy,
  wrapt,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-sqlalchemy";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    packaging
    sqlalchemy
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.sqlalchemy" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-sqlalchemy";

  meta = opentelemetry-instrumentation.meta // {
    description = "SQLAlchemy instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-sqlalchemy";
  };
}
