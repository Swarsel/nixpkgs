{
  lib,
  stdenv,
  fetchurl,
  lzip,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lzlib";
  version = "1.16";

  src = fetchurl {
    url = "mirror://savannah/lzip/lzlib/lzlib-${finalAttrs.version}.tar.lz";
    hash = "sha256-zSqW+8aF9+PcMrnw5eNARqd+PBD8/r5i+ZUeMX0KjPQ=";
    # hash from release email
  };

  outputs = [
    "out"
    "info"
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile.in --replace '-Wl,--soname=' '-Wl,-install_name,$(out)/lib/'
  '';

  nativeBuildInputs = [
    texinfo
    lzip
  ];

  configureFlags = [ "--enable-shared" ];

  makeFlags = [
    "CC:=$(CC)"
    "AR:=$(AR)"
  ];

  doCheck = true;

  meta = {
    description = "Data compression library providing in-memory LZMA compression and decompression functions, including integrity checking of the decompressed data";
    homepage = "https://www.nongnu.org/lzip/lzlib.html";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
  };
})
