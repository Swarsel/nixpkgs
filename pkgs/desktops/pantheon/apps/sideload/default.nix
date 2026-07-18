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
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "sideload";
  version = "6.3.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "sideload";
    tag = version;
    hash = "sha256-mFaMKY4SdnSdRsHy5vIbJFdMx2FGxYCWmSAWkb99yUI=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    flatpak
    glib
    granite7
    gtk4
    libxml2
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Flatpak installer, designed for elementary OS";
    homepage = "https://github.com/elementary/sideload";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.sideload";
    teams = [ lib.teams.pantheon ];
  };
}
