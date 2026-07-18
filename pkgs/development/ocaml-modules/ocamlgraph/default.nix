{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "ocamlgraph";
  version = "2.2.0";

  src = fetchurl {
    url = "https://github.com/backtracking/ocamlgraph/releases/download/${finalAttrs.version}/ocamlgraph-${finalAttrs.version}.tbz";
    hash = "sha256-sJViEIY8wk9IAgO6PC7wbfrlV5U2oFdENk595YgisjA=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Graph library for OCaml";
    homepage = "https://github.com/backtracking/ocamlgraph";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
  };
})
