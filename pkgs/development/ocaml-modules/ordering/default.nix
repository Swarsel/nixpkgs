{ buildDunePackage, dune }:

buildDunePackage {
  inherit (dune) version src;
  pname = "ordering";
  dontAddPrefix = true;

  meta = dune.meta // {
    description = "Element ordering";
  };
}
