{
  lib,
  stdenv,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  curl,
  fetchgit,
  fribidi,
  gtk2,
  harfbuzzFull,
  libGL,
  libGLU,
  libpng,
  libpthread-stubs,
  libselinux,
  libsepol,
  libxdmcp,
  pcre,
  perl,
  pkg-config,
  util-linux,
  vala,
  zlib,
}:

stdenv.mkDerivation {
  pname = "crossfire-client";
  version = "2025-01";

  src = fetchgit {
    url = "https://git.code.sf.net/p/crossfire/crossfire-client";
    rev = "c69f578add358c1db567f6b46f532dd038d2ade0";
    hash = "sha256-iFm9yVEIBwngr8/0f9TRS4Uw0hnjrW6ngMRfsWY6TX0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    perl
    vala
  ];

  buildInputs = [
    gtk2
    pcre
    zlib
    libGL
    libGLU
    libpng
    fribidi
    harfbuzzFull
    libpthread-stubs
    libxdmcp
    curl
    SDL2
    SDL2_image
    SDL2_mixer
    util-linux
    libselinux
    libsepol
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "GTKv2 client for the Crossfire free MMORPG";
    homepage = "http://crossfire.real-time.com/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "crossfire-client-gtk2";
  };
}
