{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  curl,
  doxygen,
  groff,
  gsm,
  jsoncpp,
  libgcrypt,
  libgpiod_1,
  libopus,
  libsigcxx,
  pkg-config,
  popt,
  qt5,
  rtl-sdr,
  speex,
  tcl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svxlink";
  version = "25.05.1";

  src = fetchFromGitHub {
    owner = "sm0svx";
    repo = "svxlink";
    tag = finalAttrs.version;
    hash = "sha256-OyAR/6heGX6J53p6x+ZPXY6nzSv22umMTg0ISlWcjp8=";
  };

  postPatch = ''
    # match jsoncpp's c++17 ABI (string_view overloads); upstream pins c++11
    substituteInPlace cmake/Modules/FindSIGC2.cmake \
      --replace-fail '"--std=c++11"' '"--std=c++17"'
  '';

  nativeBuildInputs = [
    cmake
    doxygen
    groff
    pkg-config
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    curl
    gsm
    jsoncpp
    libgcrypt
    libgpiod_1
    libopus
    libsigcxx
    popt
    qt5.qtbase
    rtl-sdr
    speex
    tcl
  ];

  cmakeFlags = [
    (lib.cmakeBool "DO_INSTALL_CHOWN" false)
    (lib.cmakeFeature "RTLSDR_LIBRARIES" "${lib.getLib rtl-sdr}/lib/librtlsdr.so")
    (lib.cmakeFeature "RTLSDR_INCLUDE_DIRS" "${lib.getInclude rtl-sdr}/include")
  ];

  postInstall = ''
    wrapQtApp $out/bin/qtel
  '';

  dontWrapQtApps = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Advanced repeater controller and EchoLink software";

    longDescription = ''
      Advanced repeater controller and EchoLink software for Linux including a
      GUI, Qtel - The Qt EchoLink client
    '';

    homepage = "https://www.svxlink.org/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ zaninime ];
    platforms = lib.platforms.linux;
  };
})
