{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-edit";
  version = "0.13.11";

  src = fetchFromGitHub {
    owner = "killercup";
    repo = "cargo-edit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u4mjbIs9rLZOZ4MUITc4QYnfEcTyZT5aXt6U7fwefoo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    zlib
  ];

  cargoHash = "sha256-1PCncmiY+olGGMOT2AfIbGY5sup4ysPVqdBmuecDWk0=";
  doCheck = false; # integration tests depend on changing cargo config
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility for managing cargo dependencies from the command line";
    homepage = "https://github.com/killercup/cargo-edit";
    changelog = "https://github.com/killercup/cargo-edit/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      gerschtli
      jb55
      killercup
      matthiasbeyer
    ];

    mainProgram = "cargo-edit";
  };
})
