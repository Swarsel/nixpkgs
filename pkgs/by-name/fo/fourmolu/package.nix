{
  haskell,
  haskellPackages,
}:

let
  inherit (haskell.lib.compose)
    justStaticExecutables
    ;
in
justStaticExecutables haskellPackages.fourmolu
