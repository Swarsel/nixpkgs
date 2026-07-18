{
  buildPythonPackage,
  deprecated,
  googleapis-common-protos,
  hatchling,
  opentelemetry-api,
  opentelemetry-exporter-otlp-proto-common,
  opentelemetry-proto,
  opentelemetry-sdk,
  opentelemetry-test-utils,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage {
  inherit (opentelemetry-api) version src;
  pname = "opentelemetry-exporter-otlp-proto-http";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
    responses
  ];

  build-system = [ hatchling ];

  dependencies = [
    deprecated
    googleapis-common-protos
    opentelemetry-api
    opentelemetry-exporter-otlp-proto-common
    opentelemetry-proto
    opentelemetry-sdk
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.exporter.otlp.proto.http" ];
  sourceRoot = "${opentelemetry-api.src.name}/exporter/opentelemetry-exporter-otlp-proto-http";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Collector Protobuf over HTTP Exporter";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/exporter/opentelemetry-exporter-otlp-proto-http";
  };
}
