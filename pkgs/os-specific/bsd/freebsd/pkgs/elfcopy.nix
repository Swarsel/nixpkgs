{
  compatIfNeeded,
  libarchive,
  libelf,
  libelftc,
  libpe,
  mkDerivation,
}:

mkDerivation {
  buildInputs = compatIfNeeded ++ [
    libelf
    libelftc
    libarchive
    libpe
  ];

  # since we built libpe and co separate they are not internal and thus not pie...?
  MK_PIE = "no";

  extraPaths = [
    "contrib/elftoolchain"
    "sys/sys/elf_common.h"
    "sys/sys/elf32.h"
  ];

  path = "usr.bin/elfcopy";
}
