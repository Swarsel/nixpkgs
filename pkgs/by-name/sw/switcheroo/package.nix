{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  imagemagick,
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
  pname = "switcheroo";
  version = "2.6.0";

  src = fetchFromGitLab {
    owner = "adhami3310";
    repo = "Switcheroo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yJiydJoMiDCVql1bhmh+TQi25tAy/NueHvvG4zWTTeY=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  # Workaround for the gettext-sys issue
  # https://github.com/Koka/gettext-rs/issues/114
  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.cc.isClang && lib.versionAtLeast stdenv.cc.version "16"
  ) "-Wno-error=incompatible-function-pointer-types";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ imagemagick ]}"
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    hash = "sha256-fvsR27jmL61NjvJWm7SQhiU1DMeB6OYyWQn1u+5HujM=";
    name = "switcheroo-${finalAttrs.version}";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "App for converting images between different formats";
    homepage = "https://apps.gnome.org/Converter/";
    changelog = "https://gitlab.com/adhami3310/Switcheroo/-/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "switcheroo";
    teams = [ lib.teams.gnome-circle ];
  };
})
