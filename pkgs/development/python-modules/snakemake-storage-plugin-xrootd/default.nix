{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  pkgs,
  # tests
  pytestCheckHook,
  # dependencies
  reretry,
  snakemake,
  snakemake-interface-common,
  snakemake-interface-storage-plugins,
  xrootd,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-storage-plugin-xrootd";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-storage-plugin-xrootd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vL9JD9h0ywsKpUPoXhgg6b+vwi7kxK8CF3L6HnAEidE=";
  };

  postPatch = ''
    substituteInPlace tests/tests.py \
      --replace-fail \
        'subprocess.Popen(["xrootd",' \
        'subprocess.Popen(["${lib.getExe pkgs.xrootd}",'
  '';

  # Tests fail on darwin even with:
  # - __darwinAllowLocalNetworking = true;
  # - sandbox = false
  # - writableTmpDirAsHomeHook
  #
  # Failed: XRootD server terminated unexpectedly.
  # 260604 22:16:56 259 XrdConfig: Unable to set permission for admin path /tmp/.xrd/; operation not permitted
  # ------ xrootd anon@91-224-148-58.tetaneutral.net:32293 initialization failed.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    snakemake-interface-storage-plugins
    snakemake-interface-common
    reretry
    xrootd
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  # When doCheck is disabled, nnativeCheckInputs are not available and the package fails to import:
  #   ModuleNotFoundError: No module named 'snakemake'
  pythonImportsCheck = lib.optionals finalAttrs.doCheck [ "snakemake_storage_plugin_xrootd" ];

  meta = {
    description = "Snakemake storage plugin for handling input and output via XRootD";
    homepage = "https://github.com/snakemake/snakemake-storage-plugin-xrootd";
    changelog = "https://github.com/snakemake/snakemake-storage-plugin-xrootd/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
