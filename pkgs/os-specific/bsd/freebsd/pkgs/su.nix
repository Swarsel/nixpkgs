{
  lib,
  libbsm,
  libpam,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  postPatch = ''
    sed -E -i -e '/BINOWN|BINMODE|PRECIOUSPROG/d' $BSDSRCDIR/usr.bin/su/Makefile
  '';

  buildInputs = [
    libpam
    libbsm
  ];

  path = "usr.bin/su";
  meta.mainProgram = "su";
  meta.platforms = lib.platforms.freebsd;
}
