{
  lib,
  stdenv,
  cmake,
  fetchgit,
  libarchive,
  libvorbis,
  libxml2,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stopmotion";
  version = "0.9.0";

  src = fetchgit {
    url = "https://invent.kde.org/multimedia/stopmotion";
    rev = finalAttrs.version;
    hash = "sha256-RsFqvAmTJBVg32bnY2eA9jWWnuHgv66rZiWMqa6sviw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    qt6.qtmultimedia
    libvorbis
    libarchive
    libxml2
  ];

  meta = {
    description = "Create stop-motion animation movies";
    homepage = "http://linuxstopmotion.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
    mainProgram = "stopmotion";
  };
})
