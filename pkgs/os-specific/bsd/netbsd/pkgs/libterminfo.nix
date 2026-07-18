{
  bsdSetupHook,
  compatIfNeeded,
  install,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  nbperf,
  netbsdSetupHook,
  statHook,
  tic,
  tsort,
}:

mkDerivation {
  postPatch = ''
    substituteInPlace $COMPONENT_PATH/term.c --replace /usr/share $out/share
    substituteInPlace $COMPONENT_PATH/setupterm.c \
      --replace '#include <curses.h>' 'void use_env(bool);'
  '';

  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    mandoc
    statHook
    nbperf
    tic
  ];

  buildInputs = compatIfNeeded;

  postBuild = ''
    make -C $BSDSRCDIR/share/terminfo $makeFlags BINDIR=$out/share
  '';

  postInstall = ''
    make -C $BSDSRCDIR/share/terminfo $makeFlags BINDIR=$out/share install
  '';

  SHLIBINSTALLDIR = "$(out)/lib";
  extraPaths = [ "share/terminfo" ];
  path = "lib/libterminfo";
}
