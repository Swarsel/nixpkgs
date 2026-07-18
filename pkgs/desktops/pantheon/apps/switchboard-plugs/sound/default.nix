{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  granite7,
  gtk4,
  libadwaita,
  libcanberra,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  pulseaudio,
  switchboard,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-sound";
  version = "8.0.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "settings-sound";
    tag = version;
    hash = "sha256-jiaxb8aQuGrPcIaR28L2i2J3z4eL+OdrbCJ/abuXvuY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    granite7
    gtk4
    libadwaita
    libcanberra
    libgee
    pulseaudio
    switchboard
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Sound Plug";
    homepage = "https://github.com/elementary/settings-sound";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
