{
  lib,
  stdenv,
  fetchFromGitHub,
  granite,
  gtk3,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  vala,
  wingpanel,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-a11y";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wingpanel-indicator-a11y";
    rev = version;
    sha256 = "sha256-HECK+IEUAKJ4F1TotTHF84j4BYS6EZdAtLBoM401+mw=";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    vala
  ];

  buildInputs = [
    granite
    gtk3
    libgee
    wingpanel
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal Access Indicator for Wingpanel";
    homepage = "https://github.com/elementary/wingpanel-indicator-a11y";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
