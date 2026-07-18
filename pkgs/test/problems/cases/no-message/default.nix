{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      checkMeta = true;

      problems.matchers = [
        {
          handler = "error";
          package = "a";
        }
      ];
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.description = "Some package";
  meta.problems.removal = { };
}
