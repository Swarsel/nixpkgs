{ mkDerivation }:

mkDerivation {
  MK_TESTS = "no";

  extraPaths = [
    "sys/contrib/libnv"
    "sys/sys"
  ];

  path = "lib/libnv";
}
