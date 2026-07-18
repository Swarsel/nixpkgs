{ mkDerivation }:
mkDerivation {
  preBuild = ''
    sed -i 's/4554/0554/' Makefile
  '';

  MK_TESTS = "no";
  path = "sbin/shutdown";
}
