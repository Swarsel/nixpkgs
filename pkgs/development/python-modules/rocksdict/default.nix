{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  # tests
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "rocksdict";
  version = "0.3.29";

  src = fetchFromGitHub {
    owner = "rocksdict";
    repo = "RocksDict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yP+OAVioKOGPvcYM8s1TTNHzzaFxw1sUQDrWxmptuJo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  env = {
    # libclang.so
    LIBCLANG_PATH = "${lib.getLib pkgs.libclang}/lib";
  };

  # Trace/BPT Trap 5 calling `pytest` on darwin.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src pname version;
    hash = "sha256-E7DrHMla7af7IjPxS5EV2bWorXjHCsclnONVkkLAUrk=";
  };

  enabledTestPaths = [
    "test"
  ];

  maturinBuildFlags = [
    # We disable LTO because it is incompatible with gcc
    # LTO is only supported with clang. Either disable the `lto` feature or set
    # `CC=/usr/bin/clang CXX=/usr/bin/clang++` environment variables.

    # Disable all default features to get rid of "lto"
    "--no-default-features"
    # Manually re-enable bindgen-runtime
    "--features bindgen-runtime"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rocksdict" ];

  meta = {
    description = "Python fast on-disk dictionary / RocksDB & SpeeDB Python binding";
    homepage = "https://github.com/rocksdict/RocksDict";
    changelog = "https://github.com/rocksdict/RocksDict/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
