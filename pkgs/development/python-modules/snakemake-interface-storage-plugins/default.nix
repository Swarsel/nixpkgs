{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  humanfriendly,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  reretry,
  snakemake,
  snakemake-interface-common,
  # passthru
  snakemake-interface-storage-plugins,
  snakemake-storage-plugin-http,
  tenacity,
  throttler,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-interface-storage-plugins";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-interface-storage-plugins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tqSIJnU1+DPx/GI5/wzMkoxpLyM/k/SO8FtejRv9Zls=";
  };

  # Circular dependency with snakemake
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
    snakemake-storage-plugin-http
  ];

  __structuredAttrs = true;
  build-system = [ poetry-core ];

  dependencies = [
    humanfriendly
    reretry
    snakemake-interface-common
    tenacity
    throttler
    wrapt
  ];

  disabledTests = [
    # Requires internet access
    "test_storage"
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_interface_storage_plugins" ];

  passthru.tests.pytest = snakemake-interface-storage-plugins.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Stable interface for interactions between Snakemake and its storage plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-storage-plugins";
    changelog = "https://github.com/snakemake/snakemake-interface-storage-plugins/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
