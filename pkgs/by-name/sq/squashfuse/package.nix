{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fuse3,
  libtool,
  lz4,
  lzo,
  pkg-config,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "squashfuse";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "vasi";
    repo = "squashfuse";
    rev = finalAttrs.version;
    sha256 = "sha256-hlWmHMqWl8rApogsR9uG7ZaM5dUDoTBSjSjXCKd+FIA=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libtool
    pkg-config
  ];

  buildInputs = [
    lz4
    xz
    zlib
    lzo
    zstd
    fuse3
  ];

  meta = {
    description = "FUSE filesystem to mount squashfs archives";
    homepage = "https://github.com/vasi/squashfuse";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
