{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  elfutils,
  libdwarf,
  libffi,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctypes.sh";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "taviso";
    repo = "ctypes.sh";
    rev = "v${finalAttrs.version}";
    sha256 = "1wafyfhwd7nf7xdici0djpwgykizaz7jlarn0r1b4spnpjx1zbx4";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    zlib
    libffi
    elfutils
    libdwarf
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  meta = {
    description = "Foreign function interface for bash";
    homepage = "https://github.com/taviso/ctypes.sh";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ctypes.sh";
  };
})
