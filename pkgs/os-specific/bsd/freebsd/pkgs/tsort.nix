{
  bsdSetupHook,
  freebsdSetupHook,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
}:

mkDerivation {
  outputs = [ "out" ];

  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    install
    mandoc
    groff
  ];

  makeFlags = [
    "STRIP=-s" # flag to install, not command
  ];

  MK_TESTS = "no";
  extraPaths = [ ];
  path = "usr.bin/tsort";
}
