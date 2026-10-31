{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "firezone-headless-client";
  version = "1.5.15";
  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    tag = "headless-client-${finalAttrs.version}";
    hash = "sha256-GfeER362GN5/gmiRNDCPHH5UuzWbc/EGL8MHYD8BCT0=";
  };

  cargoHash = "sha256-SogKNFicXUGoZutCV3tzhK33EWw26SOwWjh0CDWlvFU=";
  sourceRoot = "${finalAttrs.src.name}/rust";
  buildAndTestSubdir = "headless-client";
  env.RUSTFLAGS = "--cfg system_certs";

  # Required to remove profiling arguments which conflict with this builder
  postPatch = ''
    rm .cargo/config.toml
  '';

  # Required to run tests
  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  checkFlags = [
    # These tests chown the token file to root, which upstream runs as root
    # in CI but which is not possible in the build sandbox
    "--skip=tests::set_token_permissions_satisfies_check"
    "--skip=tests::token_roundtrip_write_and_read"
    "--skip=tests::write_token_creates_file_with_content"
    "--skip=tests::write_token_creates_parent_directories"
    "--skip=tests::write_token_overwrites_existing"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "headless-client-(.*)"
    ];
  };

  meta = {
    description = "CLI client for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];
    mainProgram = "firezone-headless-client";
    platforms = lib.platforms.linux;
  };
})
