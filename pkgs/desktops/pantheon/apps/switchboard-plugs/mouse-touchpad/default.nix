{
  lib,
  stdenv,
  fetchFromGitHub,
  gala, # needed for gestures support
  gettext,
  glib,
  gnome-settings-daemon,
  granite7,
  gtk4,
  libgee,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  switchboard,
  touchegg,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-mouse-touchpad";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "settings-mouse-touchpad";
    tag = version;
    hash = "sha256-KfaC1yfsL3GowcjqqwPpYQ6DJIoO7ejl0y3IQ4Gtdj8=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      touchegg = touchegg;
    })
  ];

  nativeBuildInputs = [
    gettext # msgfmt
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    gala
    glib
    granite7
    gtk4
    libgee
    libxml2
    gnome-settings-daemon
    switchboard
    touchegg
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Mouse & Touchpad Plug";
    homepage = "https://github.com/elementary/settings-mouse-touchpad";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
