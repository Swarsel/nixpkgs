{
  lib,
  stdenv,
  fetchFromGitHub,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pantheon-wayland,
  pkg-config,
  polkit,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "pantheon-agent-polkit";
  version = "8.0.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "pantheon-agent-polkit";
    rev = version;
    hash = "sha256-tuugtrnamY9QMlF/ju5+4gwcEESFqH4jDH/kz790v5Y=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    granite7
    gtk4
    libadwaita
    libgee
    pantheon-wayland
    polkit
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Polkit Agent for the Pantheon Desktop";
    homepage = "https://github.com/elementary/pantheon-agent-polkit";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
