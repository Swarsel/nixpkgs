{
  lib,
  haskell,
  haskellPackages,
}:

haskell.lib.compose.justStaticExecutables (
  haskell.lib.compose.overrideCabal (oldAttrs: {
    configureFlags = (oldAttrs.configureFlags or [ ]) ++ [ "-fbuildexe" ];
    buildDepends = (oldAttrs.buildDepends or [ ]) ++ [ haskellPackages.optparse-applicative ];

    maintainers = (oldAttrs.maintainers or [ ]) ++ [
      lib.maintainers.cdepillabout
    ];
  }) haskellPackages.pretty-simple
)
