{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers = {
        "a"."maintainerless" = "ignore";
      };
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.maintainers = [ ];
}
