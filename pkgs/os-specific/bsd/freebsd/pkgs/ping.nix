{
  lib,
  libcapsicum,
  libcasper,
  libipsec,
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -i 's/4555/0555/' $BSDSRCDIR/sbin/ping/Makefile
  '';

  buildInputs = [
    libcasper
    libcapsicum
    libipsec
  ];

  MK_TESTS = "no";
  clangFixup = true;
  path = "sbin/ping";
  meta.platforms = lib.platforms.freebsd;
}
