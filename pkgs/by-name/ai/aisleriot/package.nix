{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gnome,
  gtk3,
  guile,
  itstool,
  libcanberra-gtk3,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aisleriot";
  version = "3.22.35";

  src = fetchurl {
    url = "mirror://gnome/sources/aisleriot/${lib.versions.majorMinor finalAttrs.version}/aisleriot-${finalAttrs.version}.tar.xz";
    hash = "sha256-AeYEzXAJo2wMXxVCSpBORvg2LDBrpfa8cfrIpedGO/A=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    meson
    ninja
    pkg-config
    itstool
    libxml2
    desktop-file-utils
    yelp-tools
  ];

  buildInputs = [
    gtk3
    librsvg
    guile
    libcanberra-gtk3
  ];

  mesonFlags = [ "-Dtheme_kde=false" ];

  prePatch = ''
    patchShebangs cards/meson_svgz.sh
    patchShebangs data/meson_desktopfile.py
    patchShebangs data/icons/meson_updateiconcache.py
    patchShebangs src/lib/meson_compileschemas.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "aisleriot";
    };
  };

  meta = {
    description = "Collection of patience games written in guile scheme";
    homepage = "https://gitlab.gnome.org/GNOME/aisleriot";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "sol";
    teams = [ lib.teams.gnome ];
  };
})
