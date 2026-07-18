{ mkDerivation }:
mkDerivation {
  postPatch = ''
    sed -i /DPADD/d $BSDSRCDIR/bin/ps/Makefile
  '';

  path = "bin/ps";
}
