{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eyedropper";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "FineFindus";
    repo = "eyedropper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-008VFC2jjLWW6t6e7C8ZEoD+hFFqJVSmlgovO2RHGjw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-P5Ligi6yfSHPHjO5Gsxsf7ZbXh3GOK/q8k4GqNnsQck=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Pick and format colors";
    homepage = "https://github.com/FineFindus/eyedropper";
    changelog = "https://github.com/FineFindus/eyedropper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "eyedropper";
    teams = [ lib.teams.gnome-circle ];
  };
})
