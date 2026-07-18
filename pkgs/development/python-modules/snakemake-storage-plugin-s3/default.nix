{
  lib,
  fetchFromGitHub,
  # dependencies
  boto3,
  botocore,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  snakemake,
  snakemake-interface-common,
  snakemake-interface-storage-plugins,
  urllib3,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-storage-plugin-s3";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-storage-plugin-s3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hvyQ6V6POUBWTCWt9moQlH0RgSM4J36kjbXK4TtO8Bo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  build-system = [ poetry-core ];

  dependencies = [
    boto3
    botocore
    snakemake-interface-storage-plugins
    snakemake-interface-common
    urllib3
  ];

  disabledTests = [
    # Requires internet access
    "test_storage"

    # snakemake_interface_common.exceptions.WorkflowError: Failed to create local storage prefix .snakemake/storage/s3
    # PermissionError: [Errno 13] Permission denied: '.snakemake'
    "test_group_workflow"
    "test_simple_workflow"
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_storage_plugin_s3" ];

  meta = {
    description = "Snakemake storage plugin for S3 API storage (AWS S3, MinIO, etc.)";
    homepage = "https://github.com/snakemake/snakemake-storage-plugin-s3";
    changelog = "https://github.com/snakemake/snakemake-storage-plugin-s3/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
