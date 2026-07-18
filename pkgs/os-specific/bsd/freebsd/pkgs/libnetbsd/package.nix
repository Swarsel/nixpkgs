{
  lib,
  stdenv,
  boot-install,
  bsdSetupHook,
  freebsdSetupHook,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    mandoc
    groff
    (if stdenv.hostPlatform == stdenv.buildPlatform then boot-install else install)
  ];

  makeFlags = [
    "STRIP=-s" # flag to install, not command
    "MK_WERROR=no"
  ]
  ++ lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "INSTALL=boot-install";

  alwaysKeepStatic = true;
  path = "lib/libnetbsd";
}
