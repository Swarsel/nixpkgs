{
  lib,
  stdenv,
  fetchurl,
  tk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gocr";
  version = "0.52";

  src = fetchurl {
    url = "https://www-e.uni-magdeburg.de/jschulen/ocr/gocr-${finalAttrs.version}.tar.gz";
    sha256 = "11l6gds1lrm8lwrrsxnm5fjlwz8q1xbh896cprrl4psz21in946z";
  };

  buildFlags = [
    "all"
    "libs"
  ];

  preInstall = "mkdir -p $out/lib";

  postInstall = ''
    for i in pgm2asc.h gocr.h; do
      install -D -m644 src/$i $out/include/gocr/$i
    done
  '';

  preFixup = ''
    sed -i -e 's|exec wish|exec ${tk}/bin/wish|' $out/bin/gocr.tcl
  '';

  installFlags = [ "libdir=/lib/" ]; # Specify libdir so Makefile will also install library.

  meta = {
    description = "GPL Optical Character Recognition";
    homepage = "https://jocr.sourceforge.net/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
