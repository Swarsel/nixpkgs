{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  psq,
  qcheck-alcotest,
}:

buildDunePackage (finalAttrs: {
  pname = "lru";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/pqwy/lru/releases/download/v${finalAttrs.version}/lru-${finalAttrs.version}.tbz";
    hash = "sha256-bL4j0np9WyRPhpwLiBQNR/cPQTpkYu81wACTJdSyNv0=";
  };

  propagatedBuildInputs = [ psq ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ qcheck-alcotest ];
  duneVersion = "3";

  meta = {
    description = "Scalable LRU caches for OCaml";
    homepage = "https://github.com/pqwy/lru";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
