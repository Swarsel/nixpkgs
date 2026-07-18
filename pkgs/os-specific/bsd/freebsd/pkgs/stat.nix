{
  bsdSetupHook,
  freebsdSetupHook,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
}:

# Don't add this to nativeBuildInputs directly.  Use statHook instead.
mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    install
    mandoc
    groff
  ];

  MK_TESTS = "no";
  path = "usr.bin/stat";
}
