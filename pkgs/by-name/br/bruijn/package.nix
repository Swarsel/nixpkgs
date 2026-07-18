{
  lib,
  haskell,
  haskellPackages,
}:

let
  inherit (haskell.lib.compose) justStaticExecutables overrideCabal;

  generated = haskellPackages.callPackage ./generated.nix { };

  overrides = {
    description = "Purely functional programming language based on lambda calculus and de Bruijn indices";
    homepage = "https://bruijn.marvinborner.de/";
    passthru.updateScript = ./update.sh;
  };
in

lib.pipe generated [
  (overrideCabal overrides)
  justStaticExecutables
]
