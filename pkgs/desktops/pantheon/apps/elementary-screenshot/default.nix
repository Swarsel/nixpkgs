{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  granite7,
  gtk4,
  libportal,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-screenshot";
  version = "8.0.4";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "screenshot";
    rev = version;
    hash = "sha256-hVYzriIRvBDBdRRZRiXZwEazu9ZPhPaVY/pOfw95ZkU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    granite7
    gtk4
    libportal
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Screenshot tool designed for elementary OS";
    homepage = "https://github.com/elementary/screenshot";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.screenshot";
    teams = [ lib.teams.pantheon ];
  };
}
