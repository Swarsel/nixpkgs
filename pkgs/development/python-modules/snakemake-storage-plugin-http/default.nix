{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  # dependencies
  requests,
  requests-oauthlib,
  snakemake,
  snakemake-interface-common,
  snakemake-interface-storage-plugins,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-storage-plugin-http";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-storage-plugin-http";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ad4IOjU761CaZ+o0//I8/xW+e+4UJG0+VAbQ9KcNjFY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    requests-oauthlib
    snakemake-interface-common
    snakemake-interface-storage-plugins
  ];

  disabledTests = [
    # Requires internet access
    "test_storage"
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_storage_plugin_http" ];

  pythonRelaxDeps = [
    "requests-oauthlib"
  ];

  meta = {
    description = "Snakemake storage plugin for donwloading input files from HTTP(s)";
    homepage = "https://github.com/snakemake/snakemake-storage-plugin-http";
    changelog = "https://github.com/snakemake/snakemake-storage-plugin-http/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
