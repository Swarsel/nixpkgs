{ stdenv, mkDerivation }:
mkDerivation {
  preBuild = ''
    sed -E -i -e "s|\\$\\{INCLUDEDIR\\}|${stdenv.cc.libc}/include|g" $BSDSRCDIR/lib/libsysdecode/Makefile
  '';

  MK_TESTS = "no";

  NIX_CFLAGS_COMPILE = [
    "-Wno-unterminated-string-initialization"
  ];

  alwaysKeepStatic = true;

  extraPaths = [
    "sys"
    "libexec/rtld-elf"
  ];

  path = "lib/libsysdecode";
}
