{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  flatpak,
  gettext,
  glib,
  granite7,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  libgtop,
  libx11,
  linuxPackages,
  live-chart,
  meson,
  ninja,
  nix-update-script,
  pciutils,
  pkg-config,
  sassc,
  udisks,
  vala,
  wingpanel,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elementary-monitor";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "monitor";
    tag = finalAttrs.version;
    hash = "sha256-VlyIK7UJEHw7vvc9WEHooPSPl8OQ5ZcBrjtYrI3Qx/w=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    sassc
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    flatpak
    glib
    granite7
    gtk4
    json-glib
    libadwaita
    libgee
    libgtop
    libx11
    linuxPackages.nvidia_x11.settings.libXNVCtrl
    live-chart
    pciutils
    udisks
    wingpanel
  ];

  mesonFlags = [ "-Dindicator-wingpanel=enabled" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Manage processes and monitor system resources";
    homepage = "https://github.com/elementary/monitor";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.monitor";
    teams = [ lib.teams.pantheon ];
  };
})
