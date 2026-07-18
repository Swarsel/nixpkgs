{
  lib,
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-instrumentation-botocore,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  pytest-benchmark,
  pytestCheckHook,
  requests,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-propagator-aws-xray";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
    pytest-benchmark
    requests
  ];

  build-system = [ hatchling ];
  dependencies = [ opentelemetry-api ];
  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "opentelemetry.propagators.aws" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/propagator/opentelemetry-propagator-aws-xray";

  meta = opentelemetry-instrumentation.meta // {
    description = "AWS X-Ray Propagator for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/propagator/opentelemetry-propagator-aws-xray";
  };
}
