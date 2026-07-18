{ buildDunePackage, dune }:

buildDunePackage {
  inherit (dune) version src;
  pname = "fs-io";
  dontAddPrefix = true;

  meta = dune.meta // {
    description = "Dune's file system IO library";
  };
}
