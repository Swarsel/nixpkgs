{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-sdk,
  opentelemetry-test-utils,
  prometheus-client,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) src;
  pname = "opentelemetry-exporter-prometheus";
  # This package is in the same repository as `opentelemetry-api`,
  # but its version is synchronized with `opentelemetry-instrumentation` in another repository.
  version = opentelemetry-instrumentation.version;

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-sdk
    prometheus-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.exporter.prometheus" ];
  sourceRoot = "${opentelemetry-api.src.name}/exporter/opentelemetry-exporter-prometheus";

  meta = opentelemetry-api.meta // {
    description = "Prometheus Metric Exporter for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/exporter/opentelemetry-exporter-prometheus";
  };
}
