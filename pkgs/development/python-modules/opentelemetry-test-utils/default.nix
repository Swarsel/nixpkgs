{
  asgiref,
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-sdk,
  requests,
}:

buildPythonPackage {
  inherit (opentelemetry-api) src;
  pname = "opentelemetry-test-utils";
  # This package is in the same repository as `opentelemetry-api`,
  # but its version is synchronized with `opentelemetry-instrumentation` in another repository.
  version = opentelemetry-instrumentation.version;
  build-system = [ hatchling ];

  dependencies = [
    asgiref
    opentelemetry-api
    opentelemetry-sdk
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.test" ];
  sourceRoot = "${opentelemetry-api.src.name}/tests/opentelemetry-test-utils";

  meta = opentelemetry-api.meta // {
    description = "Test utilities for OpenTelemetry unit tests";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/tests/opentelemetry-test-utils";
  };
}
