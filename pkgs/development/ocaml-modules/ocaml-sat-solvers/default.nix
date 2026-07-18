{
  lib,
  fetchurl,
  buildDunePackage,
  minisat,
}:

buildDunePackage (finalAttrs: {
  pname = "ocaml-sat-solvers";
  version = "0.8";

  src = fetchurl {
    url = "https://github.com/tcsprojects/ocaml-sat-solvers/releases/download/v${finalAttrs.version}/ocaml-sat-solvers-${finalAttrs.version}.tbz";
    hash = "sha256-1eXzuY6rrrjdEG/XnkJe4o9zAcUvfTVFO1+ZIzcgpOU=";
  };

  propagatedBuildInputs = [ minisat ];
  minimalOCamlVersion = "4.05";

  meta = {
    description = "SAT Solvers For OCaml";
    homepage = "https://github.com/tcsprojects/ocaml-sat-solvers";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mgttlinger ];
  };
})
