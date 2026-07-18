{
  lib,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  extraPaths = [
    "usr.bin/Makefile.inc"
  ];

  path = "usr.bin/tip";
  meta.mainProgram = "tip";
  meta.platforms = lib.platforms.freebsd;
}
