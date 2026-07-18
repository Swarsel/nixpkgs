{
  compatIfNeeded,
  libelf,
  m4,
  mkDerivation,
  zlib,
}:

mkDerivation {
  buildInputs = compatIfNeeded ++ [
    zlib
    libelf
  ];

  MK_TESTS = "no";
  extraNativeBuildInputs = [ m4 ];

  extraPaths = [
    "contrib/elftoolchain/libdwarf"
    "contrib/elftoolchain/common"
    "sys/sys/elf32.h"
    "sys/sys/elf64.h"
    "sys/sys/elf_common.h"
  ];

  path = "lib/libdwarf";
}
