{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "versatiles";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "versatiles-org";
    repo = "versatiles-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZOAEdum6Zq4Qn0WvfFkiSW07aykT1OS38BxuS2Yf58A=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-J/DyJwWMMa8qaw5M5ZX2jzqt2AGyhLgp20h8gD18bKg=";
  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;

  # Skip tests that require network access
  checkFlags = [
    "--skip=tools::convert::tests::test_remote1"
    "--skip=tools::convert::tests::test_remote2"
    "--skip=tools::probe::tests::test_remote"
    "--skip=tools::serve::tests::test_config"
    "--skip=tools::serve::tests::test_remote"
    "--skip=utils::io::data_reader_http"
    "--skip=utils::io::data_reader_http::tests::read_range_git"
    "--skip=utils::io::data_reader_http::tests::read_range_googleapis"
    "--skip=io::data_reader_http::tests::read_range_git"
    "--skip=io::data_reader_http::tests::read_range_googleapis"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  # Testing only necessary for `bins`
  cargoTestFlags = [
    "--bins"
  ];

  versionCheckProgramArg = "--version";

  meta = {
    description = "Toolbox for converting, checking and serving map tiles in various formats";

    longDescription = ''
      VersaTiles is a Rust-based project designed for processing and serving tile data efficiently.
      It supports multiple tile formats and offers various functionalities for handling tile data.
    '';

    homepage = "https://versatiles.org/";
    changelog = "https://github.com/versatiles-org/versatiles-rs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wilhelmines ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "versatiles";
    downloadPage = "https://github.com/versatiles-org/versatiles-rs";
  };
})
