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
  meta.description = "Some package";

  meta.problems = {
    removal = {
      message = "This package has been abandoned upstream and will be removed";
    };

    removal2 = {
      kind = "removal";
      message = "This package has been abandoned upstream and will be removed2";
    };
  };
}
