{
  lib,
  stdenv,
  fetchurl,
  boost,
  cmake,
  gmp,
  mpfr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cgal";
  version = "5.6.3";

  src = fetchurl {
    url = "https://github.com/CGAL/cgal/releases/download/v${finalAttrs.version}/CGAL-${finalAttrs.version}.tar.xz";
    hash = "sha256-FcdDyzldGghVuQYlJfOuDNQEhkiaz+fOFFfDcQqzQRE=";
  };

  patches = [ ./cgal_path.patch ];
  nativeBuildInputs = [ cmake ];

  # note: optional component libCGAL_ImageIO would need zlib and opengl;
  #   there are also libCGAL_Qt{3,4} omitted ATM
  buildInputs = [
    boost
    gmp
    mpfr
  ];

  doCheck = false;

  meta = {
    description = "Computational Geometry Algorithms Library";
    homepage = "http://cgal.org";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
  };
})
