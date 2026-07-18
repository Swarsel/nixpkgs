{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  libGL,
  libGLU,
  libpng,
  libvorbis,
  libx11,
  libxcursor,
  libxext,
  libxpm,
  libxt,
  libxxf86dga,
  libxxf86misc,
  libxxf86vm,
  openal,
  pkg-config,
  texinfo,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "allegro";
  version = "4.4.3.1";

  src = fetchurl {
    url = "https://github.com/liballeg/allegro5/releases/download/${version}/allegro-${version}.tar.gz";
    sha256 = "1m6lz35nk07dli26kkwz3wa50jsrxs1kb6w1nj14a911l34xn6gc";
  };

  patches = [
    ./nix-unstable-sandbox-fix.patch
    ./encoding.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    texinfo
    libxext
    xorgproto
    libx11
    libxpm
    libxt
    libxcursor
    alsa-lib
    zlib
    libpng
    libvorbis
    libxxf86dga
    libxxf86misc
    libxxf86vm
    openal
    libGLU
    libGL
  ];

  cmakeFlags = [
    "-DCMAKE_SKIP_RPATH=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Game programming library";
    homepage = "https://liballeg.org/";
    license = lib.licenses.giftware;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
  };
}
