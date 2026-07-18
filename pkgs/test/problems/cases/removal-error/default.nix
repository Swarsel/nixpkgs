{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers.a.removal = "error";
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";

  meta.problems = {
    removal.message = "This package has been abandoned upstream and will be removed.";
  };
}
