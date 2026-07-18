{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
let
  version = "0.1.25";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "crates-tui";

  src = fetchFromGitHub {
    owner = "ratatui";
    repo = "crates-tui";
    tag = "v${version}";
    hash = "sha256-XQ19hfaCm7Ib9gPqu9mlmf3b8HgoyxLuBApaPeW53pI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-cGpmiUtMP/rM+712Un8GEQ51gb12maopKn0o0GTQf7M=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI for exploring crates.io using Ratatui";
    homepage = "https://github.com/ratatui/crates-tui";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ pluiedev ];

    # See Cargo.toml: workspaces.metadata.dist.targets
    # Other platforms may work but YMMV
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-windows"
    ];

    mainProgram = "crates-tui";
  };
}
