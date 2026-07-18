{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-menus,
  cinnamon-translations,
  colord,
  gettext,
  glib,
  glib-networking,
  gtk3,
  libgudev,
  libnma,
  libnotify,
  libwacom,
  libxi,
  libxml2,
  meson,
  modemmanager,
  networkmanager,
  ninja,
  pkg-config,
  polkit,
  python3,
  upower,
  wrapGAppsHook3,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-control-center";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-control-center";
    tag = finalAttrs.version;
    hash = "sha256-TjTwtTFbiC4A4qe9TIyZJtGrSymujhEgM8SpZQ92RZA=";
  };

  postPatch = ''
    patchShebangs meson_install_schemas.py
  '';

  nativeBuildInputs = [
    libxml2 # xmllint
    pkg-config
    meson
    ninja
    wrapGAppsHook3
    gettext
    python3
  ];

  buildInputs = [
    gtk3
    glib
    glib-networking
    cinnamon-desktop
    libnotify
    cinnamon-menus
    polkit
    colord
    libgudev
    libwacom
    networkmanager
    libnma
    libxi
    modemmanager
    xorgproto
    upower
  ];

  mesonFlags = [
    # use locales from cinnamon-translations
    "--localedir=${cinnamon-translations}/share/locale"
  ];

  meta = {
    description = "Collection of configuration plugins used in cinnamon-settings";
    homepage = "https://github.com/linuxmint/cinnamon-control-center";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "cinnamon-control-center";
    teams = [ lib.teams.cinnamon ];
  };
})
