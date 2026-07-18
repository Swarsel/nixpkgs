{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers = {
        "a"."deprecated" = "error";
        "a"."maintainerless" = "error";
        "a"."removal" = "error";
      };
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.description = "Some package";
  meta.maintainers = [ ];

  meta.problems = {
    deprecated.message = "Package is deprecated and replaced by b.";
    removal.message = "Package will be removed.";
  };
}
