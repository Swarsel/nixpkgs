{
  byacc,
  flex,
  mkDerivation,
}:

mkDerivation {
  extraNativeBuildInputs = [
    byacc
    flex
  ];

  extraPaths = [ "lib/libc/iconv" ];
  path = "usr.bin/mkesdb";
}
