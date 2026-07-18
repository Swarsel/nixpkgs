{
  lib,
  stdenv,
  fetchurl,
  expat,
  libxml2,
  octave,
  texinfo,
  zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gama";
  version = "2.28";

  src = fetchurl {
    url = "mirror://gnu/gama/gama-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-Xcc/4JB7hyM+KHeO32+JlQWUBfH8RXuOL3Z2P0imaxo=";
  };

  nativeBuildInputs = [
    texinfo
    zip
  ];

  buildInputs = [ expat ];
  env.CXXFLAGS = lib.optionalString stdenv.cc.isClang "-include sstream";
  doCheck = true;

  nativeCheckInputs = [
    octave
    libxml2
  ];

  meta = {
    description = "Tools for adjustment of geodetic networks";
    homepage = "https://www.gnu.org/software/gama/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
})
