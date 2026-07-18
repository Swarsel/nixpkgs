{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  buildPythonPackage,
  pkg-config,
  pytestCheckHook,
  rustPlatform,
}:
buildPythonPackage rec {
  pname = "pyoxigraph";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "oxigraph";
    repo = "oxigraph";
    tag = "v${version}";
    hash = "sha256-Sg4C9NW2grrlLFY2mDGOdsucX7cdT2028erJL8xaqLE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  buildAndTestSubdir = "python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-fR3s3RSYlpUVqsPOyPwZaCjTSNWoOYwFDBzcYxTE8kY=";
  };

  dependencies = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
  ];

  disabledTestPaths = [
    # These require network access
    "lints/test_spec_links.py"
    "lints/test_debian_compatibility.py"
    "oxrocksdb-sys/rocksdb/tools/block_cache_analyzer/block_cache_pysim_test.py"
    "oxrocksdb-sys/rocksdb/tools"
  ];

  disabledTests = [
    "test_update_load"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyoxigraph" ];

  meta = {
    description = "SPARQL graph database";
    homepage = "https://github.com/oxigraph/oxigraph";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ dadada ];
    platforms = lib.platforms.unix;
  };
}
