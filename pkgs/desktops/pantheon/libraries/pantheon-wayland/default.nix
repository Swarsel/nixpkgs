{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  gtk4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pantheon-wayland";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "pantheon-wayland";
    rev = finalAttrs.version;
    hash = "sha256-Wfulo/fXsb51ShT7E2wTg56TULAK1chB59L/ggGh2EY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
    wayland-scanner
  ];

  propagatedBuildInputs = [
    glib
    gtk4
  ];

  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland integration library to the Pantheon Desktop";
    homepage = "https://github.com/elementary/pantheon-wayland";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
})
