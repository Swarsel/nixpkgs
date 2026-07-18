{
  stdenv,
  byacc,
  flex,
  mkDerivation,
}:

mkDerivation {
  extraNativeBuildInputs = [
    byacc
    flex
  ];

  extraPaths = [
    "lib/libc/iconv"
    "lib/libiconv_modules/mapper_std"
  ];

  path = "usr.bin/mkcsmapper";
}
