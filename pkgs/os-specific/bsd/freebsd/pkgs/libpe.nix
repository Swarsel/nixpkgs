{
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e '/INTERNALLIB/d' lib/libpe/Makefile
  '';

  alwaysKeepStatic = true;

  extraPaths = [
    "contrib/elftoolchain"
    "sys/sys/elf_common.h"
  ];

  path = "lib/libpe";
}
