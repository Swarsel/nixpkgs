{
  lib,
  libbsdxml,
  libdevdctl,
  libgeom,
  libsbuf,
  libzfs,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libgeom
    libzfs
    libdevdctl
    libsbuf
    libbsdxml
  ];

  env.NIX_CFLAGS_COMPILE = "-std=c++23 -Wno-nullability-completeness";
  MK_TESTS = "no";
  clangFixup = false;

  extraPaths = [
    "sys/contrib/openzfs"
  ];

  ouptuts = [
    "out"
    "man"
    "debug"
  ];

  path = "cddl/usr.sbin/zfsd";

  meta = {
    license = with lib.licenses; [
      cddl
      bsd2
    ];

    platforms = lib.platforms.freebsd;
    mainProgram = "zfsd";
  };
}
