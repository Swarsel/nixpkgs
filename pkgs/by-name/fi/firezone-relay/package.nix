{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "firezone-relay";
  version = "0-unstable-2025-03-15";

  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    rev = "09fb5f927410503b0d6e7fc6cf6a2ba06cb5a281";
    hash = "sha256-qDeXAzOeTenL6OIsun/rEfPMo62mQT7RhJEmqemzMsM=";
  };

  # Required to remove profiling arguments which conflict with this builder
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-uqy4GgYaSX2kM4a37093lHmhvOtNUhkEs6/ZS1bjuYo=";
  env.RUSTFLAGS = "--cfg system_certs";
  buildAndTestSubdir = "relay";
  sourceRoot = "${finalAttrs.src.name}/rust";

  meta = {
    description = "STUN/TURN server for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];

    platforms = lib.platforms.linux;
    mainProgram = "firezone-relay";
  };
})
