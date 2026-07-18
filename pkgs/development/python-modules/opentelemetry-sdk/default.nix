{
  buildPythonPackage,
  flaky,
  hatchling,
  opentelemetry-api,
  opentelemetry-semantic-conventions,
  opentelemetry-test-utils,
  pytestCheckHook,
  typing-extensions,
}:

let
  self = buildPythonPackage {
    inherit (opentelemetry-api) version src;
    pname = "opentelemetry-sdk";
    doCheck = false;

    nativeCheckInputs = [
      flaky
      opentelemetry-test-utils
      pytestCheckHook
    ];

    build-system = [ hatchling ];

    dependencies = [
      opentelemetry-api
      opentelemetry-semantic-conventions
      typing-extensions
    ];

    disabledTestPaths = [ "tests/performance/benchmarks/" ];
    pyproject = true;
    pythonImportsCheck = [ "opentelemetry.sdk" ];
    sourceRoot = "${opentelemetry-api.src.name}/opentelemetry-sdk";
    # Enable tests via passthru to avoid cyclic dependency with opentelemetry-test-utils.
    passthru.tests.${self.pname} = self.overridePythonAttrs { doCheck = true; };

    meta = opentelemetry-api.meta // {
      description = "OpenTelemetry Python SDK";
      homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/opentelemetry-sdk";
    };
  };
in
self
