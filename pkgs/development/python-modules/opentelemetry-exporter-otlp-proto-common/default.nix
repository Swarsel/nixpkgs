{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-proto,
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) version src;
  pname = "opentelemetry-exporter-otlp-proto-common";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ opentelemetry-proto ];
  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.exporter.otlp.proto.common" ];
  sourceRoot = "${opentelemetry-api.src.name}/exporter/opentelemetry-exporter-otlp-proto-common";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Protobuf encoding";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/exporter/opentelemetry-exporter-otlp-proto-common";
  };
}
