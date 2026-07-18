{
  lib,
  bsdSetupHook,
  byacc,
  install,
  libcMinimal,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  openbsdSetupHook,
  statHook,
  tsort,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    openbsdSetupHook
    makeMinimal
    byacc
    install
    tsort
    lorder
    mandoc
    statHook
  ];

  libcMinimal = true;
  path = "lib/libutil";
  meta.platforms = lib.platforms.openbsd;
}
