{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-preflight";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "supinie";
    repo = "cargo-preflight";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SL8c0eLsmBfUcmhC8uuUbupDTFLQWdeqRG3ImE1smvI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-q/JbaFr1ISe0OiKeGBQQlZ2TaMTJkLABilibcp98svM=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Custom Cargo subcommand to run local 'CI' on certain Git actions";
    homepage = "https://github.com/supinie/cargo-preflight";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ supinie ];
    platforms = lib.platforms.linux;
  };
})
