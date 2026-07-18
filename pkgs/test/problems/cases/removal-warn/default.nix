{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.maintainers = [ "hello" ];
  meta.problems.removal.message = "Package to be removed.";
}
