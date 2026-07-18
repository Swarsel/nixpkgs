{
  lib,
  libelf,
  libprocstat,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libelf
    libprocstat
  ];

  extraPaths = [
    "lib/libproc/libproc.h"
  ];

  path = "lib/librtld_db";
  meta.platforms = lib.platforms.freebsd;
}
