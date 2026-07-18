{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "firezone-headless-client";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    tag = "headless-client-${finalAttrs.version}";
    hash = "sha256-yEceZJBqSF35herNjbqFHKaIoFJwbkDN28wlxFa1UbU=";
  };

  # Required to remove profiling arguments which conflict with this builder
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-3V2eMxUtNcnWsh7cYA5Wf979sKmFl7bjwwrqwcfW4tI=";
  env.RUSTFLAGS = "--cfg system_certs";

  # Required to run tests
  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  buildAndTestSubdir = "headless-client";
  sourceRoot = "${finalAttrs.src.name}/rust";

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

    platforms = lib.platforms.linux;
    mainProgram = "firezone-headless-client";
  };
})
