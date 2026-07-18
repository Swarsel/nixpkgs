{
  buildPythonPackage,
  hatchling,
  opentelemetry-instrumentation,
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (opentelemetry-instrumentation) version src;
  pname = "opentelemetry-util-http";

  nativeCheckInputs = [
    opentelemetry-instrumentation
    opentelemetry-test-utils
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  # https://github.com/open-telemetry/opentelemetry-python-contrib/issues/1940
  disabledTests = [
    "test_nonstandard_method"
    "test_nonstandard_method_allowed"
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.util.http" ];
  sourceRoot = "${opentelemetry-instrumentation.src.name}/util/opentelemetry-util-http";

  meta = opentelemetry-instrumentation.meta // {
    description = "Web util for OpenTelemetry";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/util/opentelemetry-util-http";
  };
}
