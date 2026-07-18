{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  datafusion,
  fastavro,
  pyarrow,
  pyiceberg,
  # passthru
  pyiceberg-core,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyiceberg-core";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "iceberg-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PE19tUEk3VmJ9h4JiBVYgbAVuQ3EzSngESj+CZc7ODs=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # Circular dependency on pyiceberg
  doCheck = false;

  nativeCheckInputs = [
    datafusion
    fastavro
    pyiceberg
    pyarrow
    pytestCheckHook
  ]
  ++ pyiceberg.optional-dependencies.pyarrow
  ++ pyiceberg.optional-dependencies.sql-sqlite;

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-aEk+K9dWwgkiE7Wx2J+rF3JLQ5deTqRm2sfFSphyALY=";
  };

  disabledTests = [
    # AttributeError: 'function' object has no attribute 'cache_clear'
    "test_read_manifest_entry"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyiceberg_core" ];
  sourceRoot = "${finalAttrs.src.name}/bindings/python";

  passthru.tests.pytest = pyiceberg-core.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Iceberg-rust powered core for pyiceberg";
    homepage = "https://github.com/apache/iceberg-rust/tree/main/bindings/python";
    changelog = "https://github.com/apache/iceberg-rust/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
