{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) src;
  pname = "opentelemetry-semantic-conventions";
  # This package is in the same repository as `opentelemetry-api`,
  # but its version is synchronized with `opentelemetry-instrumentation` in another repository.
  version = opentelemetry-instrumentation.version;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ opentelemetry-api ];
  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.semconv" ];
  sourceRoot = "${opentelemetry-api.src.name}/opentelemetry-semantic-conventions";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Semantic Conventions";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/opentelemetry-semantic-conventions";
  };
}
