{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "backoff";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/backoff/releases/download/${finalAttrs.version}/backoff-${finalAttrs.version}.tbz";
    hash = "sha256-AL6jEbInsbwKVYedpNzjix/YRHtOTizxk6aVNzesnwM=";
  };

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.12";

  meta = {
    description = "Exponential backoff mechanism for OCaml";
    homepage = "https://github.com/ocaml-multicore/backoff";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
