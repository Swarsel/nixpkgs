{
  lib,
  fetchurl,
  buildDunePackage,
  cmdliner,
  testo-util,
}:

buildDunePackage (finalAttrs: {
  pname = "testo";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/mjambon/testo/releases/download/${finalAttrs.version}/testo-${finalAttrs.version}.tbz";
    hash = "sha256-cPm+FSS1fCj3PCyEk37p93lHjpH6NZ3GNkKJjdExaXs=";
  };

  propagatedBuildInputs = [
    cmdliner
    testo-util
  ];

  meta = {
    description = "Test framework for OCaml";
    homepage = "https://github.com/mjambon/testo";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
