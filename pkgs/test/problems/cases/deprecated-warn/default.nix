{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers = {
        "a"."deprecated" = "warn";
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
  meta.problems.deprecated.message = "Package a is deprecated and superseeded by b.";
}
