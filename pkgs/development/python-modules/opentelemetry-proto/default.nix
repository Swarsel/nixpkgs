{
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  protobuf,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-api) version src;
  pname = "opentelemetry-proto";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ protobuf ];
  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.proto" ];
  pythonRelaxDeps = [ "protobuf" ];
  sourceRoot = "${opentelemetry-api.src.name}/opentelemetry-proto";

  meta = opentelemetry-api.meta // {
    description = "OpenTelemetry Python Proto";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/opentelemetry-proto";
  };
}
