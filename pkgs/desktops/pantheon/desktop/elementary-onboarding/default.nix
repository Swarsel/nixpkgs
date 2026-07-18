{
  lib,
  stdenv,
  fetchFromGitHub,
  appcenter,
  elementary-settings-daemon,
  glib,
  gnome-settings-daemon,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pantheon-wayland,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-onboarding";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "onboarding";
    rev = version;
    sha256 = "sha256-y5qMZoVqFpE3d6PRKDO1ldMULCaH3S4phJgAMhY2dSg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    appcenter # settings schema
    elementary-settings-daemon # settings schema
    glib
    gnome-settings-daemon # org.gnome.settings-daemon.plugins.color
    granite7
    gtk4
    libadwaita
    libgee
    pantheon-wayland
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Onboarding app for new users designed for elementary OS";
    homepage = "https://github.com/elementary/onboarding";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.onboarding";
    teams = [ lib.teams.pantheon ];
  };
}
