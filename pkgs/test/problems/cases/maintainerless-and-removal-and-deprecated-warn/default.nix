{ nixpkgs }:
let
  pkgs = import nixpkgs {
    config = {
      problems.handlers = {
        "a"."deprecated" = "warn";
        "a"."maintainerless" = "warn";
        "a"."removal" = "warn";
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
    deprecated.message = "Package will be deprecated.";
    removal.message = "Package to be removed.";
  };
}
