{
  lib,
  stdenv,
  all-cabal-hashes,
  buildHaskellPackages,
  ghc,
  haskellLib,
  pkgs,
  compilerConfig ? (self: super: { }),
  configurationArm ? import ./configuration-arm.nix,
  configurationCommon ? import ./configuration-common.nix,
  configurationDarwin ? import ./configuration-darwin.nix,
  configurationJS ? import ./configuration-ghcjs-9.x.nix,
  configurationNix ? import ./configuration-nix.nix,
  configurationWindows ? import ./configuration-windows.nix,
  initialPackages ? import ./initial-packages.nix,
  nonHackagePackages ? import ./non-hackage-packages.nix,
  overrides ? (self: super: { }),
  packageSetConfig ? (self: super: { }),
}:

let

  inherit (lib) extends makeExtensible;
  inherit (haskellLib) makePackageSet;

  haskellPackages = pkgs.callPackage makePackageSet {
    inherit
      stdenv
      haskellLib
      ghc
      extensible-self
      all-cabal-hashes
      buildHaskellPackages
      ;

    package-set = initialPackages;
  };

  platformConfigurations =
    lib.optionals stdenv.hostPlatform.isAarch [
      (configurationArm { inherit pkgs haskellLib; })
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      (configurationDarwin { inherit pkgs haskellLib; })
    ]
    ++ lib.optionals stdenv.hostPlatform.isWindows [
      (configurationWindows { inherit pkgs haskellLib; })
    ]
    ++ lib.optionals stdenv.hostPlatform.isGhcjs [
      (configurationJS { inherit pkgs haskellLib; })
    ];

  extensions = lib.composeManyExtensions (
    [
      (nonHackagePackages { inherit pkgs haskellLib; })
      (configurationNix { inherit pkgs haskellLib; })
      (configurationCommon { inherit pkgs haskellLib; })
    ]
    ++ platformConfigurations
    ++ [
      compilerConfig
      packageSetConfig
      overrides
    ]
  );

  extensible-self = makeExtensible (extends extensions haskellPackages);

in

extensible-self
