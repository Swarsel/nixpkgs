{
  lib,
  stdenv,
  fetchFromGitHub,
  gcr_4,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-capnet-assist";
  version = "8.0.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "capnet-assist";
    rev = version;
    sha256 = "sha256-HowrCYOVSYSOCRpTIXFfw4lLUulXY6j5QcxJOBMo984=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gcr_4
    granite7
    gtk4
    libadwaita
    libgee
    webkitgtk_6_0
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Small WebKit app that assists a user with login when a captive portal is detected";
    homepage = "https://github.com/elementary/capnet-assist";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.capnet-assist";
    teams = [ lib.teams.pantheon ];
  };
}
