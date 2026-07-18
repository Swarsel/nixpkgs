{ callPackage, idris2 }:
{
  inherit idris2;
  buildIdris = callPackage ./build-idris.nix { };
  idris2Api = callPackage ./idris2-api.nix { };
  idris2Lsp = callPackage ./idris2-lsp.nix { };
  pack = callPackage ./pack.nix { };
}
