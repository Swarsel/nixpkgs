{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  curl,
  fetchpatch,
  ffmpeg_7,
  flam3,
  glee,
  libGL,
  libGLU,
  libglut,
  libgtop,
  libpng,
  libxrender,
  lua5_1,
  pkg-config,
  tinyxml,
  wxwidgets_3_2,
}:

stdenv.mkDerivation {
  pname = "electricsheep";
  version = "3.0.2-unstable-2024-02-13";

  src = fetchFromGitHub {
    owner = "scottdraves";
    repo = "electricsheep";
    rev = "5fbbb684752be06ccbea41639968aa7f1cc678dd";
    hash = "sha256-X3EZ1/VcLEU1GkZbskWSsqQWYTnsH3pbFDvDLpdLmcU=";
  };

  patches = [
    # <https://github.com/scottdraves/electricsheep/pull/126>
    ./boost-1.85.patch
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-wCRT0pSC9w+XXAbeCTukvPMu5mVeGdfwnkBieMmBIwA=";
      url = "https://gitweb.gentoo.org/repo/proj/guru.git/plain/app-misc/electricsheep/files/electricsheep-boost-system-r1.patch?id=b9f2c3c92d29ed57491a88e45dc8a99bbc73fc15";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    wxwidgets_3_2
    ffmpeg_7
    lua5_1
    curl
    libpng
    libxrender
    flam3
    libgtop
    boost
    tinyxml
    libglut
    libGLU
    libGL
    glee
  ];

  configureFlags = [
    "CPPFLAGS=-I${glee}/include/GL"
  ];

  makeFlags = [
    ''CXXFLAGS+="-DGL_GLEXT_PROTOTYPES"''
  ];

  preBuild = ''
    sed -i "s|/usr|$out|" Makefile
  '';

  preAutoreconf = ''
    cd client_generic
    sed -i '/ACX_PTHREAD/d' configure.ac
  '';

  meta = {
    description = "Electric Sheep, a distributed screen saver for evolving artificial organisms";
    homepage = "https://electricsheep.org/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
