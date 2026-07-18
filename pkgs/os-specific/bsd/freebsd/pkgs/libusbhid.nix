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

  path = "lib/libusbhid";
  meta.platforms = lib.platforms.freebsd;
}
