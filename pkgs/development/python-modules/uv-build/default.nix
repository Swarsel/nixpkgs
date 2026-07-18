{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  pkgs,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.11.16";

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-5LJspcHj/RjOMv7eRB7n+tofX4s51M3kqHCPymCg90A=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # The package has no tests
  doCheck = false;
  buildAndTestSubdir = "crates/uv-build";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-2lg86WxPGVbJ91zi61lKrSqnzFgmmSrBrl+SfV5SJWU=";
  };

  # $src/.github/workflows/build-binaries.yml#L139
  maturinBuildProfile = "minimal-size";
  pyproject = true;
  pythonImportsCheck = [ "uv_build" ];

  # Run the tests of a package built by `uv_build`.
  passthru = {
    tests.built-by-uv = callPackage ./built-by-uv.nix { };

    # updateScript is not needed here, as updating is done on staging
  };

  meta = {
    inherit (pkgs.uv.meta) license;
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    changelog = "https://github.com/astral-sh/uv/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ bengsparks ];
  };
})
