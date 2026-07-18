{
  lib,
  aws-xray-sdk,
  botocore,
  buildPythonPackage,
  hatchling,
  moto,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-propagator-aws-xray,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  pytest-vcr,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-instrumentation-botocore";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytest-vcr
    pytestCheckHook
  ];

  checkInputs = [
    aws-xray-sdk
    moto
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-propagator-aws-xray
    opentelemetry-semantic-conventions
  ];

  disabledTests = [
    "test_scan"
  ];

  optional-dependencies = {
    instruments = [ botocore ];
  };

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation.botocore" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/instrumentation/opentelemetry-instrumentation-botocore";

  meta = opentelemetry-instrumentation.meta // {
    description = "Botocore instrumentation for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/blob/main/instrumentation/opentelemetry-instrumentation-botocore";
  };
}
