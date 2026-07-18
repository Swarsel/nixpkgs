{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      allowBroken = true;
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.broken = true;
  meta.description = "Some package";
  meta.maintainers = [ "hello" ];
}
