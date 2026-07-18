{
  lib,
  stdenv,
  fetchFromGitHub,
  geoclue2,
  geocode-glib_2,
  glib,
  granite7,
  gtk4,
  libadwaita,
  libshumate,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elementary-maps";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "maps";
    tag = finalAttrs.version;
    hash = "sha256-tS8UnW/oNjLaUZ1XgGuAmeMrHEa2jbtBc0xMcTKki1k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    geoclue2
    geocode-glib_2
    glib
    granite7
    gtk4
    libadwaita
    libshumate
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Map viewer designed for elementary OS";
    homepage = "https://github.com/elementary/maps";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.maps";
    teams = [ lib.teams.pantheon ];
  };
})
