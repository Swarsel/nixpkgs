{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  pydantic,
  # tests
  pytestCheckHook,
  rich,
  snakemake,
  snakemake-interface-executor-plugins,
  snakemake-interface-logger-plugins,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-logger-plugin-rich";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "cademirch";
    repo = "snakemake-logger-plugin-rich";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vdPM1nRovZ5QhKudzCebMNMndzOWPvTmI5I1oTbzg9o=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    pydantic
    rich
    snakemake-interface-executor-plugins
    snakemake-interface-logger-plugins
  ];

  pyproject = true;
  pythonImportsCheck = [ "snakemake_logger_plugin_rich" ];

  meta = {
    description = "Snakemake logger plugin using Rich";
    homepage = "https://github.com/cademirch/snakemake-logger-plugin-rich";
    changelog = "https://github.com/cademirch/snakemake-logger-plugin-rich/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
