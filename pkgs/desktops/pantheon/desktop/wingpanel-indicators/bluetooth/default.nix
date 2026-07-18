{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  granite,
  gtk3,
  libgee,
  libnotify,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wingpanel,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-bluetooth";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wingpanel-indicator-bluetooth";
    rev = version;
    sha256 = "sha256-N0ehiK8sYAZ/3Lu2u7dut7ZflroFptALFCxjbI0++BA=";
  };

  nativeBuildInputs = [
    glib # for glib-compile-schemas
    libxml2
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    granite
    gtk3
    libgee
    libnotify
    wingpanel
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Bluetooth Indicator for Wingpanel";
    homepage = "https://github.com/elementary/wingpanel-indicator-bluetooth";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.bluetooth";
    teams = [ lib.teams.pantheon ];
  };
}
