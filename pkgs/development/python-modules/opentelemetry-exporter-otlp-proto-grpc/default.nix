{
  buildPythonPackage,
  deprecated,
  googleapis-common-protos,
  grpcio,
  hatchling,
  opentelemetry-api,
  opentelemetry-exporter-otlp-proto-common,
  opentelemetry-proto,
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) version src;
  pname = "opentelemetry-exporter-otlp-proto-grpc";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    deprecated
    googleapis-common-protos
    grpcio
    opentelemetry-api
    opentelemetry-exporter-otlp-proto-common
    opentelemetry-proto
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.exporter.otlp.proto.grpc" ];
  sourceRoot = "${opentelemetry-api.src.name}/exporter/opentelemetry-exporter-otlp-proto-grpc";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Collector Protobuf over gRPC Exporter";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/exporter/opentelemetry-exporter-otlp-proto-grpc";
  };
}
