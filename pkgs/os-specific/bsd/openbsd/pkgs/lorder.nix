{
  lib,
  bsdSetupHook,
  install,
  makeMinimal,
  mkDerivation,
  openbsdSetupHook,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    openbsdSetupHook
    makeMinimal
    install
  ];

  noCC = true;
  path = "usr.bin/lorder";
  meta.platforms = lib.platforms.unix;
}
