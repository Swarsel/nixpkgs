{
  lib,
  stdenv,
  buildPythonPackage,
  grpcio,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  pytestCheckHook,
  wrapt,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-grpc";

  env = {
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  };

  preBuild = ''
    export TMPDIR=$(mktemp -d)
  '';

  nativeCheckInputs = [
    opentelemetry-test-utils
    grpcio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    wrapt
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # RuntimeError: Failed to bind to address
    "TestOpenTelemetryServerInterceptorUnix"
  ];

  optional-dependencies = {
    instruments = [ grpcio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.grpc" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-grpc";

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Instrumentation for grpc";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/instrumentation/opentelemetry-instrumentation-grpc";
  };
}
