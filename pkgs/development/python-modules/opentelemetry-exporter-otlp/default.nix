{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-exporter-otlp-proto-grpc,
  opentelemetry-exporter-otlp-proto-http,
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) version src;
  pname = "opentelemetry-exporter-otlp";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-exporter-otlp-proto-grpc
    opentelemetry-exporter-otlp-proto-http
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.exporter.otlp" ];
  sourceRoot = "${opentelemetry-api.src.name}/exporter/opentelemetry-exporter-otlp";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Collector Exporters";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/exporter/opentelemetry-exporter-otlp";
  };
}
