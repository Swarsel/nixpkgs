{
  byacc,
  libevent,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i 's/DPADD/#DPADD/' $BSDSRCDIR/sbin/slaacd/Makefile
  '';

  buildInputs = [ libevent ];
  extraNativeBuildInputs = [ byacc ];
  path = "sbin/slaacd";
}
