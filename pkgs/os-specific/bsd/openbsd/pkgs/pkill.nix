{
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i /DPADD/d $BSDSRCDIR/usr.bin/pkill/Makefile
  '';

  path = "usr.bin/pkill";
}
