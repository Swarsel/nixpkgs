{ mkDerivation }:
mkDerivation {
  extraPaths = [ "sbin/dhcpleased" ];
  path = "usr.sbin/dhcpleasectl";

}
