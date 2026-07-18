{ nixpkgs }:
let
  lib = pkgs.lib;
  pkgs = import nixpkgs {
    config = {
      problems.handlers.a.broken = "ignore";
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
