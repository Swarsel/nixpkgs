{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  bcg729,
  bison,
  ccrtp,
  cmake,
  file,
  flex,
  ilbc,
  libsForQt5,
  libsndfile,
  libxml2,
  readline,
  speex,
  ucommon,
}:

stdenv.mkDerivation rec {
  pname = "twinkle";
  version = "unstable-2024-20-11";

  src = fetchFromGitHub {
    owner = "LubosD";
    repo = "twinkle";
    rev = "e067dcba28f4e2acd7f71b875fc4168e9706aaaa";
    hash = "sha256-3YtZwP/ugWOSfUa4uaEAEEsk9i5j93eLt5lHgAu5qqI=";
  };

  nativeBuildInputs = [
    cmake
    bison
    flex
    bcg729
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libxml2
    file # libmagic
    libsndfile
    readline
    ucommon
    ccrtp
    libsForQt5.qtbase
    libsForQt5.qttools
    libsForQt5.qtquickcontrols2
    alsa-lib
    speex
    ilbc
  ];

  cmakeFlags = [
    "-DWITH_G729=On"
    "-DWITH_SPEEX=On"
    "-DWITH_ILBC=On"
    "-DHAVE_LIBATOMIC=atomic"
    # "-DWITH_DIAMONDCARD=On" seems ancient and broken
  ];

  meta = {
    description = "SIP-based VoIP client";
    homepage = "http://twinkle.dolezel.info/";
    changelog = "https://github.com/LubosD/twinkle/blob/${version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.mkg20001 ];
    platforms = lib.platforms.linux;
  };
}
