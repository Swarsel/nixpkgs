{ lib, mkDerivation }:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  SHLIBINSTALLDIR = "$(out)/lib";
  libcMinimal = true;
  path = "lib/libcrypt";
  meta.platforms = lib.platforms.netbsd;
}
