{
  lib,
  fetchurl,
  buildOctavePackage,
}:

buildOctavePackage rec {
  pname = "cgi";
  version = "0.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/octave/${pname}-${version}.tar.gz";
    sha256 = "0hygj7cpwrs2w9bfb7qrvv7gq410bfiddqvza8smg766pqmfp1s1";
  };

  meta = {
    description = "Common Gateway Interface for Octave";
    homepage = "https://gnu-octave.github.io/packages/cgi/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
