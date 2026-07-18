{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  opentelemetry-api,
  opentelemetry-test-utils,
  pytestCheckHook,
  setuptools,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "opentelemetry-instrumentation";
  version = "0.64b0";

  # To avoid breakage, every package in opentelemetry-python-contrib must inherit this version, src, and meta
  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-python-contrib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dOcDzJD1xxCN7+Zrn+2mF/gbZjy/XC6uAKDhpfYLf98=";
  };

  nativeCheckInputs = [
    opentelemetry-test-utils
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    setuptools
    wrapt
  ];

  disabledTests = [
    # bootstrap: error: argument -a/--action: invalid choice: 'pipenv' (choose from install, requirements)
    # RuntimeError: Patch is already started
    "test_run_cmd_install"
    "test_run_cmd_print"
    "test_run_unknown_cmd"
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.instrumentation" ];
  sourceRoot = "${finalAttrs.src.name}/opentelemetry-instrumentation";
  passthru.updateScript = opentelemetry-api.updateScript;

  meta = {
    description = "Instrumentation Tools & Auto Instrumentation for OpenTelemetry Python";
    homepage = "https://github.com/open-telemetry/opentelemetry-python-contrib/tree/main/opentelemetry-instrumentation";
    changelog = "https://github.com/open-telemetry/opentelemetry-python-contrib/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.natsukium ];
  };
})
