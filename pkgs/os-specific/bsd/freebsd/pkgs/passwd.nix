{
  lib,
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
    sed -E -i -e '/BINOWN|BINMODE|PRECIOUSPROG/d' $BSDSRCDIR/usr.bin/passwd/Makefile
  '';

  buildInputs = [
    libpam
  ];

  path = "usr.bin/passwd";
  meta.mainProgram = "passwd";
  meta.platforms = lib.platforms.freebsd;
}
