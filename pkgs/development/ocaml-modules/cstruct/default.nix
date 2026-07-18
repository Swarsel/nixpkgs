{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  crowbar,
  fmt,
}:

buildDunePackage (finalAttrs: {
  pname = "cstruct";
  version = "6.2.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-cstruct/releases/download/v${finalAttrs.version}/cstruct-${finalAttrs.version}.tbz";
    hash = "sha256-mngHM5JYDoNJFI+jq0sbLpidydMNB0AbBMlrfGDwPmI=";
  };

  buildInputs = [ fmt ];
  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Access C-like structures directly from OCaml";
    homepage = "https://github.com/mirage/ocaml-cstruct";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
