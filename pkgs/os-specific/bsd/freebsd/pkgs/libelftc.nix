{
  compatIfNeeded,
  libelf,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e '/INTERNALLIB/d' lib/libelftc/Makefile
  '';

  buildInputs = compatIfNeeded ++ [
    libelf
  ];

  alwaysKeepStatic = true;

  extraPaths = [
    "contrib/elftoolchain"
    "sys/sys/elf_common.h"
  ];

  path = "lib/libelftc";
}
