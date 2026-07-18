{
  lib,
  bsdSetupHook,
  defaultMakeFlags,
  install,
  lorder,
  makeMinimal,
  mkDerivation,
  netbsdSetupHook,
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
    netbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    rpcgen
    statHook
  ];

  makeFlags = defaultMakeFlags ++ [ "INCSDIR=$(dev)/include/rpcsvc" ];
  libcMinimal = true;
  path = "lib/librpcsvc";
  meta.platforms = lib.platforms.netbsd;
}
