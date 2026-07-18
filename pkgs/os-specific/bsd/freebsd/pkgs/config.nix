{
  bsdSetupHook,
  byacc,
  compatIfNeeded,
  file2c,
  flex,
  freebsdSetupHook,
  groff,
  install,
  libnv,
  libsbuf,
  makeMinimal,
  mandoc,
  mkDerivation,
}:

mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    install
    mandoc
    groff

    flex
    byacc
    file2c
  ];

  buildInputs = compatIfNeeded ++ [
    libnv
    libsbuf
  ];

  path = "usr.sbin/config";
}
