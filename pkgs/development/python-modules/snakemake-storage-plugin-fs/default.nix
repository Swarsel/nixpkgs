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
  snakemake-interface-storage-plugins,
  sysrsync,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-storage-plugin-fs";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-storage-plugin-fs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UdK0yhl7ljLh57CXAvH/OYiVyw+BjhPwGjSBXX8sbZk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    snakemake-interface-common
    snakemake-interface-storage-plugins
    sysrsync
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_storage_plugin_fs" ];

  meta = {
    description = "Snakemake storage plugin that reads and writes from a locally mounted filesystem using rsync";
    homepage = "https://github.com/snakemake/snakemake-storage-plugin-fs";
    changelog = "https://github.com/snakemake/snakemake-storage-plugin-fs/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
