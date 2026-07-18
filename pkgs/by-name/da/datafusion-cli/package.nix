{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "datafusion-cli";
  version = "54.0.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "datafusion";
    tag = finalAttrs.version;
    hash = "sha256-BWpHiLCn7idvzI2rlsre8l23TbxQU1Ma6bCjAMxQ6m8=";
    name = "datafusion-cli-source";
  };

  cargoHash = "sha256-Sj/biBiJPIYwxpL+Fua0k47vOu6gyyAhcKb4ZSUli6k=";
  # timeout
  doCheck = false;

  checkFlags = [
    # Some tests not found fake path
    "--skip=catalog::tests::query_gs_location_test"
    "--skip=catalog::tests::query_http_location_test"
    "--skip=catalog::tests::query_s3_location_test"
    "--skip=exec::tests::copy_to_external_object_store_test"
    "--skip=exec::tests::copy_to_object_store_table_s3"
    "--skip=exec::tests::create_object_store_table_cos"
    "--skip=exec::tests::create_object_store_table_http"
    "--skip=exec::tests::create_object_store_table_oss"
    "--skip=exec::tests::create_object_store_table_s3"
    "--skip=tests::test_parquet_metadata_works_with_strings"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildAndTestSubdir = "datafusion-cli";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for Apache Arrow DataFusion";
    homepage = "https://arrow.apache.org/datafusion";
    changelog = "https://github.com/apache/datafusion/blob/${finalAttrs.src.tag}/datafusion/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "datafusion-cli";
  };
})
