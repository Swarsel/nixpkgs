{
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-sdk,
  # tests
  opentelemetry-test-utils,
  pytestCheckHook,
}:

buildPythonPackage rec {
  inherit (opentelemetry-instrumentation) src version;
  pname = "opentelemetry-distro";

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-sdk
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.distro" ];
  sourceRoot = "${src.name}/opentelemetry-distro";
  passthru.updateScript = opentelemetry-api.updateScript;

  meta = opentelemetry-instrumentation.meta // {
    description = "OpenTelemetry Python Distro";
    homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/opentelemetry-distro";
  };
}
