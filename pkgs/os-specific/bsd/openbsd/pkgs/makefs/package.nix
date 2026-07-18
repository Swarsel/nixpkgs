{ lib, mkDerivation }:
mkDerivation {
  patches = [ ./compat.patch ];

  preBuild = ''
    mkdir -p $BSDSRCDIR/usr.sbin/makefs/include
    ln -s $BSDSRCDIR $BSDSRCDIR/usr.sbin/makefs/include/bsdroot
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$BSDSRCDIR/usr.sbin/makefs/include"
  '';

  extraPaths = [
    "sys/sys"
    "sys/ufs"
    "sys/msdosfs"
    "sys/dev"
  ];

  path = "usr.sbin/makefs";
  meta.platforms = lib.platforms.all;
}
