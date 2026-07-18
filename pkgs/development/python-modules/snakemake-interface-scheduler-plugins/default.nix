{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  pytestCheckHook,
  snakemake,
  # dependencies
  snakemake-interface-common,
  # passthru
  snakemake-interface-scheduler-plugins,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-interface-scheduler-plugins";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-interface-scheduler-plugins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BowMwZllFR9IKYUMhISAbf606awTxfmS/nQxkGgb4y8=";
  };

  # Circular dependency with snakemake
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    snakemake-interface-common
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_interface_scheduler_plugins" ];

  passthru.tests.pytest = snakemake-interface-scheduler-plugins.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Provides a stable interface for interactions between Snakemake and its scheduler plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-scheduler-plugins";
    changelog = "https://github.com/snakemake/snakemake-interface-scheduler-plugins/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kyehn ];
  };
})
