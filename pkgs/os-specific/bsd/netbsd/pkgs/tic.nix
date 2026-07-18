{
  bsdSetupHook,
  compatIfNeeded,
  defaultMakeFlags,
  groff,
  install,
  libterminfo,
  makeMinimal,
  mandoc,
  mkDerivation,
  nbperf,
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
    nbperf
  ];

  buildInputs = compatIfNeeded;
  makeFlags = defaultMakeFlags ++ [ "TOOLDIR=$(out)" ];
  HOSTPROG = "tic";

  extraPaths = [
    libterminfo.path
    "usr.bin/tic"
    "tools/Makefile.host"
  ];

  path = "tools/tic";
}
