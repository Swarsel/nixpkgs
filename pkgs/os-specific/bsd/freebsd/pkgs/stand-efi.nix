{
  lib,
  stdenv,
  buildPackages,
  elfcopy,
  freebsd-lib,
  include,
  mkDerivation,
  vtfontcvt,
}:
let
  hostArchBsd = freebsd-lib.mkBsdArch stdenv;
in
mkDerivation {
  postPatch = ''
    sed -E -i -e 's|/bin/pwd|${buildPackages.coreutils}/bin/pwd|' $BSDSRCDIR/stand/defs.mk
    #sed -E -i -e 's|-e start|-Wl,-e,start|g' $BSDSRCDIR/stand/i386/Makefile.inc $BSDSRCDIR/stand/i386/*/Makefile
  '';

  makeFlags = [
    "STRIP=-s" # flag to install, not command
    "MK_MAN=no"
    "MK_TESTS=no"
    "OBJCOPY=${lib.getBin buildPackages.binutils-unwrapped}/bin/${buildPackages.binutils-unwrapped.targetPrefix}objcopy"
  ]
  ++ lib.optional (!stdenv.hostPlatform.isFreeBSD) "MK_WERROR=no";

  # ???
  preBuild = ''
    NIX_CFLAGS_COMPILE+=" -I${include}/include -I$BSDSRCDIR/sys/sys -I$BSDSRCDIR/sys/${hostArchBsd}/include -fno-stack-protector"
    export NIX_CFLAGS_COMPILE

    make -C $BSDSRCDIR/stand/libsa $makeFlags
    make -C $BSDSRCDIR/stand/libsa32 $makeFlags
    make -C $BSDSRCDIR/stand/ficl $makeFlags
    make -C $BSDSRCDIR/stand/liblua $makeFlags
    make -C $BSDSRCDIR/stand/liblua32 $makeFlags
  '';

  postInstall = ''
    mkdir -p $out/bin/lua
    cp $BSDSRCDIR/stand/lua/*.lua $out/bin/lua
    cp -r $BSDSRCDIR/stand/defaults $out/bin/defaults
  '';

  extraNativeBuildInputs = [
    vtfontcvt
    elfcopy
  ];

  extraPaths = [
    "contrib/bzip2"
    "contrib/llvm-project/compiler-rt/lib/builtins"
    "contrib/lua"
    "contrib/pnglite"
    "contrib/terminus"
    "lib/libc"
    "lib/liblua"
    "libexec/flua"
    #"lib/flua"
    "stand"
    "sys"
  ];

  hardeningDisable = [
    "stackprotector"
    "fortify"
  ];

  path = "stand/efi";
  meta.platforms = lib.platforms.freebsd;
}
