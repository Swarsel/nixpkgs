{ mkDerivation }:
mkDerivation {
  postPatch = ''
    sed -i /DPADD/d $BSDSRCDIR/sbin/dmesg/Makefile
  '';

  path = "sbin/dmesg";
}
