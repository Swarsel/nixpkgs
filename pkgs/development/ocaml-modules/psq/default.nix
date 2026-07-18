{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  qcheck-alcotest,
  seq,
}:

buildDunePackage (finalAttrs: {
  pname = "psq";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/pqwy/psq/releases/download/v${finalAttrs.version}/psq-${finalAttrs.version}.tbz";
    hash = "sha256-QgBfUz6r50sXme4yuJBWVM1moivtSvK9Jmso2EYs00Q=";
  };

  propagatedBuildInputs = [ seq ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ qcheck-alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Functional Priority Search Queues for OCaml";
    homepage = "https://github.com/pqwy/psq";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
