{
  lib,
  compatIfNeeded,
  libdwarf,
  libelf,
  libspl,
  mkDerivation,
  zlib,
}:

mkDerivation {
  buildInputs = compatIfNeeded ++ [
    libdwarf
    zlib
    libspl
    libelf
  ];

  makeFlags = [
    "STRIP=-s"
    "MK_WERROR=no"
    "MK_TESTS=no"
  ];

  OPENSOLARIS_SYS_DISTDIR = "$(SRCTOP)/sys/cddl/contrib/opensolaris";
  OPENSOLARIS_USR_DISTDIR = "$(SRCTOP)/cddl/contrib/opensolaris";

  extraPaths = [
    "cddl/compat/opensolaris"
    "cddl/contrib/opensolaris"
    "sys/cddl/compat/opensolaris"
    "sys/cddl/contrib/opensolaris"
    "sys/contrib/openzfs"
  ];

  path = "cddl/usr.bin/ctfconvert";
  meta.license = lib.licenses.cddl;
}
