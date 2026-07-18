{
  lib,
  buildDunePackage,
  csexp,
  dune,
  dyn,
  ocamlc-loc,
  ordering,
  pp,
  stdune,
  xdg,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "dune-rpc";

  propagatedBuildInputs = [
    csexp
    stdune
    ocamlc-loc
    ordering
    pp
    xdg
    dyn
  ];

  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage;
    description = "Library to connect and control a running dune instance";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
