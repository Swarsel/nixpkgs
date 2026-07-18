{
  lib,
  buildDunePackage,
  csexp,
  dune,
  dyn,
  fs-io,
  ocaml,
  ordering,
  pp,
  top-closure,
  version ? if lib.versionAtLeast ocaml.version "4.13" then dune.version else "3.22.2",
}:

buildDunePackage {
  inherit version;
  inherit (dune.override { inherit version; }) src;
  pname = "stdune";

  propagatedBuildInputs = [
    dyn
    ordering
    pp
    csexp
    fs-io
    top-closure
  ];

  dontAddPrefix = true;

  meta = dune.meta // {
    description = "Dune's unstable standard library";
  };
}
