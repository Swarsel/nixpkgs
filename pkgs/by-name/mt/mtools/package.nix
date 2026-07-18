{
  lib,
  stdenv,
  fetchurl,
  libiconv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mtools";
  version = "4.0.49";

  src = fetchurl {
    url = "mirror://gnu/mtools/mtools-${finalAttrs.version}.tar.bz2";
    hash = "sha256-b+UZNYPW58Wdp15j1yNPdsCwfK8zsQOJT0b2aocf/J8=";
  };

  outputs = [
    "out"
    "info"
    "man"
  ];

  patches = lib.optional stdenv.hostPlatform.isDarwin ./UNUSED-darwin.patch;
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;
  # fails to find X on darwin
  configureFlags = lib.optional stdenv.hostPlatform.isDarwin "--without-x";
  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Utilities to access MS-DOS disks";
    homepage = "https://www.gnu.org/software/mtools/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
})
