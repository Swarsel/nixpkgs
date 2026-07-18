{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers = {
        "a"."deprecated" = "error";
      };
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.maintainers = [ "hello" ];

  meta.problems.deprecated = {
    message = "Package is deprecated and replaced by b";
  };
}
