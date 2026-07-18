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

  path = "usr.bin/fstat";
  meta.mainProgram = "fstat";
  meta.platforms = lib.platforms.freebsd;
}
