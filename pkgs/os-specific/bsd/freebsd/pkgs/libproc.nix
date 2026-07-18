{
  lib,
  libctf,
  librtld-db,
  mkDerivation,
  zlib,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    libctf
    librtld-db
    zlib
  ];

  MK_TESTS = "no";

  extraPaths = [
    "sys/contrib/openzfs/include"
    "sys/contrib/openzfs/lib/libspl/include"
    "sys/contrib/openzfs/lib/libspl/include"
    "sys/contrib/openzfs/include/os/freebsd/spl/sys/ccompile.h"
    "cddl/contrib/opensolaris/lib/libctf/common"
    "sys/cddl/contrib/opensolaris/uts/common"
    "sys/cddl/compat/opensolaris"
  ];

  path = "lib/libproc";
  meta.platforms = lib.platforms.freebsd;
}
