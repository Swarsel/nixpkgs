{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  path = "sbin/reboot";
}
