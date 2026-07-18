{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-calendar,
  evolution-data-server,
  granite,
  gtk3,
  libgee,
  libhandy,
  libical,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  vala,
  wingpanel,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-datetime";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wingpanel-indicator-datetime";
    rev = version;
    sha256 = "sha256-iR80pF3KUe0WboFm2/f1ZK9/wER2LfmRBd92e8jGTHs=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      elementary_calendar = elementary-calendar;
    })
  ];

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    evolution-data-server
    granite
    gtk3
    libgee
    libhandy
    libical
    wingpanel
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Date & Time Indicator for Wingpanel";
    homepage = "https://github.com/elementary/wingpanel-indicator-datetime";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
