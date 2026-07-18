{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-notifications,
  granite,
  gtk3,
  libgee,
  libhandy,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wingpanel,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-notifications";
  version = "7.1.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wingpanel-indicator-notifications";
    rev = version;
    sha256 = "sha256-fuC9ldDjKuy1kBeFOAIZ/Onhl2o45Xj+YjSrfYz1xvw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    elementary-notifications
    granite
    gtk3
    libgee
    libhandy
    wingpanel
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Notifications Indicator for Wingpanel";
    homepage = "https://github.com/elementary/wingpanel-indicator-notifications";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
