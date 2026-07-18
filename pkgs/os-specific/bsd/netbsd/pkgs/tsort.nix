{
  bsdSetupHook,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
  netbsdSetupHook,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    mandoc
    groff
  ];

  path = "usr.bin/tsort";
}
