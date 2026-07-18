{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xsl,
  gtk2,
  gtk3,
  intltool,
  libx11,
  libxslt,
  pkg-config,
  wrapGAppsHook3,
  withGtk3 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxappearance";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxappearance";
    tag = finalAttrs.version;
    hash = "sha256-t5P3JYGZzhTaJ3s23r6yrAQoFcCV5uteHh67sWY1KrI=";
  };

  patches = [
    ./lxappearance-0.6.3-xdg.system.data.dirs.patch
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
    wrapGAppsHook3
    autoreconfHook
    libxslt
    docbook_xsl
  ];

  buildInputs = [
    libx11
    (if withGtk3 then gtk3 else gtk2)
  ];

  configureFlags = lib.optional withGtk3 "--enable-gtk3";
  env.XSLTPROC = lib.getExe' libxslt "xsltproc";
  enableParallelBuilding = true;

  meta = {
    description = "Lightweight program for configuring the theme and fonts of gtk applications";
    homepage = "https://lxde.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "lxappearance";
  };
})
