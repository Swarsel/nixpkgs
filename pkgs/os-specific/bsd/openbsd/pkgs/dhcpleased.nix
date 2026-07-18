{
  byacc,
  libevent,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i 's/DPADD/#DPADD/' $BSDSRCDIR/sbin/dhcpleased/Makefile
  '';

  buildInputs = [ libevent ];
  extraNativeBuildInputs = [ byacc ];
  path = "sbin/dhcpleased";
}
