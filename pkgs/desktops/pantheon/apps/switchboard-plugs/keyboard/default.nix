{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-settings-daemon,
  gettext,
  gnome-settings-daemon,
  granite7,
  gsettings-desktop-schemas,
  gtk4,
  ibus,
  libadwaita,
  libgee,
  libgnomekbd,
  libxklavier,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  switchboard,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-keyboard";
  version = "8.1.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "settings-keyboard";
    rev = version;
    sha256 = "sha256-JuFx0PkbB6ctXhqtORlgtSq9oigaLL2N4IKX7NQgHcU=";
  };

  patches = [
    # This will try to install packages with apt.
    # https://github.com/elementary/settings-keyboard/issues/324
    ./hide-install-unlisted-engines-button.patch

    # We no longer ship Pantheon X11 session in NixOS.
    # https://github.com/elementary/session-settings/issues/91
    # https://github.com/elementary/session-settings/issues/82
    ./hide-onscreen-keyboard-settings.patch

    (replaceVars ./fix-paths.patch {
      inherit libgnomekbd;
    })
  ];

  nativeBuildInputs = [
    gettext # msgfmt
    libxml2
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    elementary-settings-daemon # io.elementary.settings-daemon.applications
    gnome-settings-daemon # media-keys
    granite7
    gsettings-desktop-schemas
    gtk4
    ibus
    libadwaita
    libgee
    libxklavier
    switchboard
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Keyboard Plug";
    homepage = "https://github.com/elementary/settings-keyboard";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
