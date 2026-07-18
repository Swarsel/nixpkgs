{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  sassc,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "switchboard";
  version = "8.0.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "switchboard";
    rev = version;
    hash = "sha256-pVXcY/QSjgBcTr0sFQnPxICoQ0tpy2fEJ687zHEDXA0=";
  };

  patches = [
    ./plugs-path-env.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sassc
    vala
    wrapGAppsHook4
  ];

  propagatedBuildInputs = [
    # Required by switchboard-3.pc.
    glib
    granite7
    gtk4
    libadwaita
    libgee
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extensible System Settings app for Pantheon";
    homepage = "https://github.com/elementary/switchboard";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.settings";
    teams = [ lib.teams.pantheon ];
  };
}
