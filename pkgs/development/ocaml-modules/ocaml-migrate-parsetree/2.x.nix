{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
}:

buildDunePackage (finalAttrs: {
  pname = "ocaml-migrate-parsetree";
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/ocaml-ppx/ocaml-migrate-parsetree/releases/download/${finalAttrs.version}/ocaml-migrate-parsetree-${finalAttrs.version}.tbz";
    sha256 = "sha256-7EnEUtwzemIFVqtoK/AZi/UBglULUC2PsjClkSYKpqQ=";
  };

  minimalOCamlVersion = "4.02";

  meta = {
    description = "Convert OCaml parsetrees between different major versions";
    homepage = "https://github.com/ocaml-ppx/ocaml-migrate-parsetree";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      vbgl
      sternenseemann
    ];

    broken = lib.versionAtLeast ocaml.version "5.1";
  };
})
