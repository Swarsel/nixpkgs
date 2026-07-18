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

  path = "lib/libnetgraph";
  meta.platforms = lib.platforms.freebsd;
}
