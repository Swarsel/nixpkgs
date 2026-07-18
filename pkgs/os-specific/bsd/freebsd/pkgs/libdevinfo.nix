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

  path = "lib/libdevinfo";
  meta.platforms = lib.platforms.freebsd;
}
