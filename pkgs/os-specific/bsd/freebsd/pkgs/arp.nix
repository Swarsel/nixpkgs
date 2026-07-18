{
  lib,
  libxo,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [ libxo ];
  path = "usr.sbin/arp";
  meta.mainProgram = "arp";
  meta.platforms = lib.platforms.freebsd;
}
