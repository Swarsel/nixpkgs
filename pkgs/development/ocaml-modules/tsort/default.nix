{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  containers,
}:

buildDunePackage rec {
  pname = "tsort";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "dmbaturin";
    repo = "ocaml-tsort";
    rev = version;
    sha256 = "sha256-/gxjXDRhQdbt0ZBdCNk/j1oWhAbm2UOfye2D9QvPr3o=";
  };

  propagatedBuildInputs = [ containers ];

  meta = {
    inherit (src.meta) homepage;
    description = "Easy to use and user-friendly topological sort";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
