{
  lib,
  stdenv,
  fetchurl,
  asciidoctor,
  libpng,
  netpbm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sng";
  version = "1.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/sng/sng-${finalAttrs.version}.tar.xz";
    hash = "sha256-yb37gPWhfbGquTN7rtZKjr6lwN34KRXGiHuM+4fs5h4=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;
  nativeBuildInputs = [ asciidoctor ];
  buildInputs = [ libpng ];

  makeFlags = [
    "prefix=$(out)"
    "MANDIR=$(outputMan)/share/man"
    "RGBTXT=${netpbm.out}/share/netpbm/misc/rgb.txt"
  ];

  meta = {
    description = "Minilanguage designed to represent the entire contents of a PNG file in an editable form";
    homepage = "https://sng.sourceforge.net/";
    license = lib.licenses.zlib;

    maintainers = [
    ];

    platforms = lib.platforms.unix;
    mainProgram = "sng";
  };
})
