{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  onnxruntime,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hieroglyphic";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "FineFindus";
    repo = "Hieroglyphic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uCzxv3jyBIFXYoEk2q26rB0Me3MAt1NiINulA1FjQtA=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    appstream
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    onnxruntime
    openssl
  ];

  env = {
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_STRATEGY = "system";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-vqTySi22Gi4WrkNolAIFFbpSmIzjgbIcmW0gkStK6H4=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool based on detexify for finding LaTeX symbols from drawings";
    homepage = "https://apps.gnome.org/en/Hieroglyphic/";
    changelog = "https://github.com/FineFindus/Hieroglyphic/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    # Note: upstream currently has case-insensititvity issues on darwin
    # https://github.com/FineFindus/Hieroglyphic/issues/40
    platforms = lib.platforms.linux;
    mainProgram = "hieroglyphic";
    teams = [ lib.teams.gnome-circle ];
  };
})
