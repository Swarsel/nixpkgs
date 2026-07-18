{ mkDerivation }:
mkDerivation {
  postPatch = ''
    sed -i /DPADD/d $BSDSRCDIR/usr.bin/vmstat/Makefile
  '';

  path = "usr.bin/vmstat";
}
