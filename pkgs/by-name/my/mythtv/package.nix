{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoconf,
  automake,
  exiv2,
  fftwSinglePrec,
  file,
  freetype,
  lame,
  libGL,
  libGLU,
  libbluray,
  libhdhomerun,
  libpulseaudio,
  libsForQt5,
  libsamplerate,
  libtool,
  libuuid,
  libx11,
  libxinerama,
  libxmu,
  libxrandr,
  libxv,
  libxvmc,
  libxxf86vm,
  libzip,
  linuxHeaders,
  lzo,
  perl,
  pkg-config,
  soundtouch,
  taglib,
  which,
  yasm,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "mythtv";
  version = "35.0";

  src = fetchFromGitHub {
    owner = "MythTV";
    repo = "mythtv";
    tag = "v${version}";
    hash = "sha256-4mWtPJi2CBoek8LWEfdFxe1ybomAOCTWBTKExMm7nLU=";
  };

  patches = [
    # Disable sourcing /etc/os-release
    ./dont-source-os-release.patch
  ];

  nativeBuildInputs = [
    pkg-config
    which
    yasm
    libtool
    autoconf
    automake
    file
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    freetype
    libsForQt5.qtbase
    libsForQt5.qtscript
    lame
    zlib
    libGLU
    libGL
    perl
    libsamplerate
    libbluray
    lzo
    alsa-lib
    libpulseaudio
    fftwSinglePrec
    libx11
    libxv
    libxrandr
    libxvmc
    libxmu
    libxinerama
    libxxf86vm
    libxmu
    libuuid
    taglib
    exiv2
    soundtouch
    libzip
    libhdhomerun
  ];

  configureFlags = [ "--dvb-path=${linuxHeaders}/include" ];
  enableParallelBuilding = true;
  setSourceRoot = "sourceRoot=$(echo */mythtv)";

  meta = {
    description = "Open Source DVR";
    homepage = "https://www.mythtv.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
