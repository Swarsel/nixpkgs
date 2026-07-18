{ mkDerivation }:

mkDerivation {
  env.MK_TESTS = "no";
  extraPaths = [ "sys/kern" ];
  path = "lib/libsbuf";
}
