{
  lib,
  stdenv,
  bsdSetupHook,
  defaultMakeFlags,
  groff,
  install,
  makeMinimal,
  mandoc,
  mkDerivation,
  nbperf,
  netbsdSetupHook,
  rpcgen,
}:

mkDerivation {
  # The makefiles define INCSDIR per subdirectory, so we have to set
  # something else on the command line so those definitions aren't
  # overridden.
  postPatch = ''
    find "$BSDSRCDIR" -name Makefile -exec \
      sed -i -E \
        -e 's_/usr/include_''${INCSDIR0}_' \
        {} \;
  '';

  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    mandoc
    groff
    nbperf
    rpcgen
  ];

  makeFlags = defaultMakeFlags ++ [ "RPCGEN_CPP=${stdenv.cc.cc}/bin/cpp" ];

  # multiple header dirs, see above
  postConfigure = ''
    makeFlags=''${makeFlags/INCSDIR/INCSDIR0}
  '';

  extraPaths = [ "common" ];
  headersOnly = true;
  noCC = true;
  noLibc = true;
  path = "include";
  meta.platforms = lib.platforms.netbsd;
}
