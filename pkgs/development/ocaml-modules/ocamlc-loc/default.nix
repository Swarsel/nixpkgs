{
  lib,
  buildDunePackage,
  dune,
  dyn,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "ocamlc-loc";
  propagatedBuildInputs = [ dyn ];
  dontAddPrefix = true;

  meta = {
    description = "Parse ocaml compiler output into structured form";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
