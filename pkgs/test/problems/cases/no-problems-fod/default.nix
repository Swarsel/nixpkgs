{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
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
  outputHash = pkgs.lib.fakeHash;
  meta.description = "Some package";
}
