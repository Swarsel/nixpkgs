{ mkDerivation }:
mkDerivation {
  extraPaths = [ "sbin/slaacd" ];
  path = "usr.sbin/slaacctl";

}
