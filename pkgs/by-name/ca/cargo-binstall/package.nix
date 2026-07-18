{
  lib,
  fetchFromGitHub,
  bzip2,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  xz,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-binstall";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "cargo-bins";
    repo = "cargo-binstall";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6msYAVCN1i2srA4DquqcdJxUrJP1jub34c/a/4RbWCg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    xz
    zstd
  ];

  cargoHash = "sha256-r9iGWxrLlD83QtvZuWXIxjI2S0RO1GNwOed531FVvJk=";

  checkFlags = [
    # requires internet access
    "--skip=download::test::test_and_extract"
    "--skip=gh_api_client::test::test_gh_api_client_cargo_binstall_no_such_release"
    "--skip=gh_api_client::test::test_gh_api_client_cargo_binstall_v0_20_1"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  buildFeatures = [
    "fancy-no-backtrace"
    "git"
    "pkg-config"
    "rustls"
    "trust-dns"
    "zstd-thin"
  ];

  buildNoDefaultFeatures = true;

  cargoBuildFlags = [
    "-p"
    "cargo-binstall"
  ];

  cargoTestFlags = [
    "-p"
    "cargo-binstall"
  ];

  versionCheckProgramArg = "-V";

  meta = {
    description = "Tool for installing rust binaries as an alternative to building from source";
    homepage = "https://github.com/cargo-bins/cargo-binstall";
    changelog = "https://github.com/cargo-bins/cargo-binstall/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
    mainProgram = "cargo-binstall";
  };
})
