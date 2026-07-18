{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  snakemake,
  # dependencies
  snakemake-interface-common,
  # passthru
  snakemake-interface-report-plugins,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-interface-report-plugins";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-interface-report-plugins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3ugEmdO1dcusKXXBZBRszlZXX5fhJyYSSF5Uj5CKJkQ=";
  };

  # Circular dependency with snakemake
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    snakemake-interface-common
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_interface_report_plugins" ];

  passthru.tests.pytest = snakemake-interface-report-plugins.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Interface for Snakemake report plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-report-plugins";
    changelog = "https://github.com/snakemake/snakemake-interface-report-plugins/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
