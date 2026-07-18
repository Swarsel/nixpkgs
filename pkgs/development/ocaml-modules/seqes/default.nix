{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  qcheck,
  qcheck-alcotest,
}:

buildDunePackage rec {
  pname = "seqes";
  version = "0.4";

  src = fetchurl {
    url = "https://gitlab.com/raphael-proust/seqes/-/archive/${version}/seqes-${version}.tar.gz";
    hash = "sha256-E4BalN68CJP7u6NSC0XBooWvUeSNqV+3KEOtoJ4g/dM=";
  };

  doCheck = true;

  checkInputs = [
    qcheck
    qcheck-alcotest
    alcotest
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "Variations of the Seq module with monads folded into the type";
    homepage = "https://gitlab.com/nomadic-labs/seqes";
    license = lib.licenses.lgpl2; # Same as OCaml
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
