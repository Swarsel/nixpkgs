{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lobtui";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "pythops";
    repo = "lobtui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ig/KdCuQZYSiCydouN29IsIRKh8qngtzcOknTozDRRM=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-Cj6hf/dizIv2pKbQvyRqqIz5k3AW3cdfpCaIHvk8G9o=";

  meta = {
    description = "TUI for lobste.rs website";
    homepage = "https://github.com/pythops/lobtui";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lobtui";
  };
})
