{
  lib,
  stdenv,
  autoreconfHook,
  binutils-unwrapped_2_38,
  bison,
  buildPackages,
  libbfd_2_38,
  libiberty,
}:

stdenv.mkDerivation {
  inherit (binutils-unwrapped_2_38) version src;
  pname = "libopcodes";

  outputs = [
    "out"
    "dev"
  ];

  patches = binutils-unwrapped_2_38.patches ++ [
    ./build-components-separately.patch
  ];

  # We just want to build libopcodes
  postPatch = ''
    cd opcodes
    find . ../include/opcode -type f -exec sed {} -i -e 's/"bfd.h"/<bfd.h>/' \;
  '';

  nativeBuildInputs = [
    autoreconfHook
    bison
  ];

  buildInputs = [ libiberty ];
  # dis-asm.h includes bfd.h
  propagatedBuildInputs = [ libbfd_2_38 ];

  configureFlags = [
    "--enable-targets=all"
    "--enable-64-bit-bfd"
    "--enable-install-libbfd"
    "--enable-shared"
  ];

  configurePlatforms = [
    "build"
    "host"
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  meta = {
    description = "Library from binutils for manipulating machine code";
    homepage = "https://www.gnu.org/software/binutils/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ericson2314 ];
    platforms = lib.platforms.unix;
  };
}
