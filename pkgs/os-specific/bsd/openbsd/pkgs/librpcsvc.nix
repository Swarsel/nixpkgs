{
  lib,
  bsdSetupHook,
  install,
  lorder,
  makeMinimal,
  mkDerivation,
  openbsdSetupHook,
  rpcgen,
  statHook,
  tsort,
}:

mkDerivation {
  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    openbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    rpcgen
    statHook
  ];

  makeFlags = [ "INCSDIR=$(dev)/include/rpcsvc" ];
  libcMinimal = true;
  path = "lib/librpcsvc";
  meta.platforms = lib.platforms.openbsd;
}
