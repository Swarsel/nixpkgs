{
  lib,
  bsdSetupHook,
  byacc,
  flex,
  freebsdSetupHook,
  gencat,
  include,
  install,
  makeMinimal,
  mkDerivation,
  versionData,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    install

    flex
    byacc
    gencat
  ];

  buildInputs = [ include ];
  MK_TESTS = "no";

  extraPaths = [
    "lib/Makefile.inc"
    "lib/libc/include/libc_private.h"
  ]
  ++ lib.optionals (versionData.major >= 14) [ "sys/sys/param.h" ];

  noLibc = true;
  path = "lib/csu";
  meta.platforms = lib.platforms.freebsd;
}
