{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  c-ares,
  cmake,
  doxygen,
  fuse3,
  libevent,
  openssl,
  pkg-config,
  systemd,
  tcp_wrappers,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apt-cacher-ng";
  version = "3.7.5";

  src = fetchurl {
    url = "mirror://debian/pool/main/a/apt-cacher-ng/apt-cacher-ng_${finalAttrs.version}.orig.tar.xz";
    hash = "sha256-LkiH1ocDljNJkqzNMx4Sy6ht/vhXUy9hC7BjWo4ykA0=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    pkg-config
  ];

  buildInputs = [
    bzip2
    fuse3
    libevent
    xz
    openssl
    systemd
    tcp_wrappers
    zlib
    c-ares
  ];

  meta = {
    description = "Caching proxy specialized for Linux distribution files";
    homepage = "https://www.unix-ag.uni-kl.de/~bloch/acng/";
    license = lib.licenses.bsdOriginal;
    maintainers = [ lib.maintainers.makefu ];
    platforms = lib.platforms.linux;
    mainProgram = "apt-cacher-ng";
  };
})
