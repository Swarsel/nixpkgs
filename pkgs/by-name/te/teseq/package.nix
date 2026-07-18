{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "1.1.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "teseq";

  src = fetchurl {
    url = "mirror://gnu/teseq/teseq-${version}.tar.gz";
    sha256 = "08ln005qciy7f3jhv980kfhhfmh155naq59r5ah9crz1q4mx5yrj";
  };

  meta = {
    description = "Escape sequence illuminator";
    homepage = "https://www.gnu.org/software/teseq/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.vaibhavsagar ];
    platforms = lib.platforms.unix;
  };
}
