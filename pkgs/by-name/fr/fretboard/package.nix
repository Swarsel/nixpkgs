{
  lib,
  stdenv,
  fetchFromGitHub,
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
  pname = "fretboard";
  version = "9.1";

  src = fetchFromGitHub {
    owner = "bragefuglseth";
    repo = "fretboard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LTUZPOecX1OiLcfdiY/P2ffq91QcnFjW6knM9H/Z+Lc=";
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

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Gl78z9FR/sB14uFDLKgnfN4B5yOi6A6MH64gDXcLiWA=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Look up guitar chords";
    homepage = "https://apps.gnome.org/Fretboard/";
    changelog = "https://github.com/bragefuglseth/fretboard/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "fretboard";
    teams = [ lib.teams.gnome-circle ];
  };
})
