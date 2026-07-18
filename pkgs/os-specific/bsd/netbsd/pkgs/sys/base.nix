{
  lib,
  bsdSetupHook,
  config,
  defaultMakeFlags,
  genassym,
  include,
  install,
  lorder,
  makeMinimal,
  mkDerivation,
  netbsdSetupHook,
  statHook,
  tsort,
  uudecode,
}:
{
  patches = [
    # Fix this error when building bootia32.efi and bootx64.efi:
    # error: PHDR segment not covered by LOAD segment
    ./no-dynamic-linker.patch

    # multiple header dirs, see above
    ./sys-headers-incsdir.patch
  ];

  postPatch = ''
    substituteInPlace sys/arch/i386/stand/efiboot/Makefile.efiboot \
      --replace "-nocombreloc" "-z nocombreloc"
  ''
  +
    # multiple header dirs, see above
    include.postPatch;

  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    statHook
    uudecode
    config
    genassym
  ];

  propagatedBuildInputs = [ include ];
  makeFlags = defaultMakeFlags ++ [ "FIRMWAREDIR=$(out)/libdata/firmware" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=array-parameter"
    "-Wno-error=array-bounds"
    "-Wa,--no-warn"
  ];

  postConfigure = ''
    pushd arch/$MACHINE/conf
    config $CONFIG
    popd
  ''
  # multiple header dirs, see above
  + include.postConfigure;

  postBuild = ''
    make -C arch/$MACHINE/compile/$CONFIG $makeFlags
  '';

  postInstall = ''
    cp arch/$MACHINE/compile/$CONFIG/netbsd $out
  '';

  CONFIG = "GENERIC";
  MKKMOD = "no";

  extraPaths = [
    "common"
    "lib/libossaudio"
  ];

  hardeningDisable = [ "pic" ];
  path = "sys";

  postIncludes = ''
    install $BSDSRCDIR/lib/libossaudio/soundcard.h $out/include/soundcard.h
  '';

  # Make the build ignore linker warnings
  prePatch = ''
    substituteInPlace sys/conf/Makefile.kern.inc \
      --replace "-Wa,--fatal-warnings" ""
  '';

  meta.platforms = lib.platforms.netbsd;
}
