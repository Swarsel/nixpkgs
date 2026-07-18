{
  lib,
  fetchurl,
  buildOctavePackage,
  gsl,
  matgeom,
}:

buildOctavePackage rec {
  pname = "geometry";
  version = "4.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/octave/${pname}-${version}.tar.gz";
    sha256 = "sha256-28FliEXJfS1mh8FJCmG0PTWZE9M0IOR1tlnzNfejQ2A=";
  };

  buildInputs = [
    gsl
  ];

  requiredOctavePackages = [
    matgeom
  ];

  meta = {
    description = "Library for extending MatGeom functionality";
    homepage = "https://gnu-octave.github.io/packages/geometry/";

    license = with lib.licenses; [
      gpl3Plus
      boost
    ];

    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
