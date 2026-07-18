{ mkDerivation }:
mkDerivation {
  postPatch = ''
    sed -i /BINMODE/d $BSDSRCDIR/usr.bin/wall/Makefile
    sed -i /BINGRP/d $BSDSRCDIR/usr.bin/wall/Makefile
  '';

  path = "usr.bin/wall";
}
