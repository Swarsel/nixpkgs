{
  lib,
  libutil,
  libxo,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libutil
    libxo
  ];

  path = "sbin/mount";
  meta.platforms = lib.platforms.freebsd;
}
