{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-settings-daemon,
  gala,
  gettext,
  gexiv2,
  glib,
  gnome-settings-daemon,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  switchboard,
  vala,
  wingpanel,
  wingpanel-indicator-keyboard,
  wingpanel-quick-settings,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-pantheon-shell";
  version = "8.3.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "settings-desktop";
    tag = version;
    hash = "sha256-qczv+G0v47SiMsLlWjDPK0ZY4J+V/CXe/l7b6pWG+WY=";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    elementary-settings-daemon
    gnome-settings-daemon
    gala
    gexiv2
    glib
    granite7
    gtk4
    libadwaita
    libgee
    switchboard
    wingpanel
    wingpanel-indicator-keyboard # gsettings schemas
    wingpanel-quick-settings # gsettings schemas
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Desktop Plug";
    homepage = "https://github.com/elementary/settings-desktop";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
