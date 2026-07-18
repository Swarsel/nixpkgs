{ buildDunePackage, dune }:

buildDunePackage {
  inherit (dune) version src;
  pname = "top-closure";
  dontAddPrefix = true;

  meta = dune.meta // {
    description = "Dune's topological closure library";
  };
}
