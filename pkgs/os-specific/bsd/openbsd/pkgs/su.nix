{
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i /BINMODE/d $BSDSRCDIR/usr.bin/su/Makefile
  '';

  path = "usr.bin/su";
  meta.mainProgram = "su";
}
