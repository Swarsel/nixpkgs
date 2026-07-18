{
  lib,
  Agda,
  config,
  newScope,
  pkgs,
}:

let
  mkAgdaPackages = Agda: lib.makeScope newScope (mkAgdaPackages' Agda);
  mkAgdaPackages' =
    Agda: self:
    let
      inherit (self) callPackage;
      inherit
        (callPackage ../build-support/agda {
          inherit Agda self;
          inherit (pkgs.haskellPackages) ghcWithPackages;
        })
        withPackages
        mkLibraryFile
        mkDerivation
        ;
    in
    {
      inherit mkLibraryFile mkDerivation;
      _1lab = callPackage ../development/libraries/agda/1lab { };
      agda = withPackages [ ];
      agda-categories = callPackage ../development/libraries/agda/agda-categories { };
      agda-prelude = callPackage ../development/libraries/agda/agda-prelude { };
      agda2hs-base = callPackage ../development/libraries/agda/agda2hs-base { };
      agdarsec = callPackage ../development/libraries/agda/agdarsec { };
      cubical = callPackage ../development/libraries/agda/cubical { };
      cubical-mini = callPackage ../development/libraries/agda/cubical-mini { };
      functional-linear-algebra = callPackage ../development/libraries/agda/functional-linear-algebra { };
      generics = callPackage ../development/libraries/agda/generics { };
      iowa-stdlib = callPackage ../development/libraries/agda/iowa-stdlib { };
      lib = lib.extend (final: prev: import ../build-support/agda/lib.nix { lib = prev; });
      standard-library = callPackage ../development/libraries/agda/standard-library { };
    }
    // lib.optionalAttrs config.allowAliases {
      generic = throw "agdaPackages.generic has been removed because it is unmaintained upstream and has been marked as broken since 2021. Consider using agdaPackages.generics instead."; # Added 2025-10-11
    };
in
mkAgdaPackages Agda
