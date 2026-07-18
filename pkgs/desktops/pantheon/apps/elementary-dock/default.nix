{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  granite7,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wayland,
  wayland-scanner,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elementary-dock";
  version = "8.3.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "dock";
    rev = finalAttrs.version;
    hash = "sha256-13wXBqN4vovmiXXQyciy4yxIrByuLBvm+ypg2MLVMB4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wayland-scanner
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    granite7
    gtk4
    libadwaita
    wayland
  ];

  # Fix building with GCC 14
  # https://github.com/elementary/dock/issues/418
  env.NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion";
  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Elegant, simple, clean dock";
    homepage = "https://github.com/elementary/dock";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.dock";
    teams = [ lib.teams.pantheon ];
  };
})
