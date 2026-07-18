{
  bsdSetupHook,
  byacc,
  cksum,
  compatIfNeeded,
  flex,
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
    byacc
    flex
  ];

  buildInputs = compatIfNeeded;
  env.NIX_CFLAGS_COMPILE = toString [ "-DMAKE_BOOTSTRAP" ];
  extraPaths = [ cksum.path ];
  path = "usr.bin/config";
}
