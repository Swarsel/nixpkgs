{
  lib,
  Vpl,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  pname = "VplTactic";
  buildInputs = [ coq.ocamlPackages.vpl-core ];
  propagatedBuildInputs = [ Vpl ];
  defaultVersion = if lib.versions.isEq "8.9" coq.version then "0.5" else null;
  mlPlugin = true;
  owner = "VERIMAG-Polyhedra";
  release."0.5".hash = "sha256-4h0hyvj9R+GOgnGWQFDi0oENLZPiJoimyK1q327qvIY=";
  release."0.5".rev = "487e3aff8446bed2c5116cefc7d71d98a06e85de";

  meta = Vpl.meta // {
    description = "Coq Tactic for Arithmetic (based on VPL)";
  };
}
