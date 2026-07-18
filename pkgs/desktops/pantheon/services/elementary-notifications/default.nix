{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  granite7,
  gtk4,
  libadwaita,
  libcanberra,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wayland-scanner,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-notifications";
  version = "8.1.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "notifications";
    tag = version;
    hash = "sha256-qod76RSsCO9NvjnYTLRW6P1UyR1K6Uu9fEjU2WgHUWk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib # for glib-compile-schemas
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
    libcanberra
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "GTK notification server for Pantheon";
    homepage = "https://github.com/elementary/notifications";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.notifications";
    teams = [ lib.teams.pantheon ];
  };
}
