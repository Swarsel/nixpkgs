{
  buildPythonPackage,
  hatchling,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-dbapi,
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-sqlite3";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-instrumentation
    opentelemetry-instrumentation-dbapi
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.sqlite3" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-sqlite3";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry SQLite3 instrumentation";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-sqlite3";
  };
}
