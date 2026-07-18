{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  pytestCheckHook,
  # dependencies
  snakemake-interface-common,
  # passthru
  snakemake-interface-logger-plugins,
  snakemake-logger-plugin-rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-interface-logger-plugins";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-interface-logger-plugins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UBdzJtKukR4Y9KPpu8qJv4HmN9ghncvEqGsTQnHk36k=";
  };

  # Circular dependency with snakemake
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake-logger-plugin-rich
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
  pythonImportsCheck = [ "snakemake_interface_logger_plugins" ];

  passthru.tests.pytest = snakemake-interface-logger-plugins.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Stable interface for interactions between Snakemake and its logger plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-logger-plugins";
    changelog = "https://github.com/snakemake/snakemake-interface-logger-plugins/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
