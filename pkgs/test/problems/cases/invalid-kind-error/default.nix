{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config.checkMeta = true;
    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";

  meta.problems = {
    invalid.message = "No maintainers";
  };
}
