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
  meta.description = "Some package";
  meta.maintainers = [ "hello" ];

  meta.problems.removal = {
    message = "Removed because of XYZ.";

    urls = [
      "https://example.com"
      "https://anotherexample.com"
    ];
  };
}
