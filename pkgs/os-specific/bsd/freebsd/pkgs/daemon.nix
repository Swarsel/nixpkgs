{ mkDerivation }:
mkDerivation {
  MK_TESTS = "no";
  path = "usr.sbin/daemon";
}
