{ callPackage }:

let
  # Common passthru for all perl interpreters.
  # copied from lua
  passthruFun =
    {
      overrides,
      perlOnBuildForBuild,
      perlOnBuildForHost,
      perlOnBuildForTarget,
      perlOnHostForHost,
      perlOnTargetForTarget,
      self, # is perlOnHostForTarget
      perlAttr ? null,
      tests ? { },
    }:
    let
      perlPackages =
        callPackage
          # Function that when called
          # - imports perl-packages.nix
          # - adds spliced package sets to the package set
          (
            {
              stdenv,
              callPackage,
              makeScopeWithSplicing',
              perl,
              pkgs,
            }:
            let
              perlPackagesFun = callPackage ../../../top-level/perl-packages.nix {
                inherit stdenv pkgs;
                perl = self;
              };

              otherSplices = {
                selfBuildBuild = perlOnBuildForBuild.pkgs;
                selfBuildHost = perlOnBuildForHost.pkgs;
                selfBuildTarget = perlOnBuildForTarget.pkgs;
                selfHostHost = perlOnHostForHost.pkgs;
                selfTargetTarget = perlOnTargetForTarget.pkgs or { };
              };
            in
            makeScopeWithSplicing' {
              inherit otherSplices;
              f = perlPackagesFun;
            }
          )
          {
            perl = self;
          };
    in
    rec {
      inherit tests;

      buildEnv = callPackage ./wrapper.nix {
        inherit (pkgs) requiredPerlModules;
        perl = self;
      };

      interpreter = "${self}/bin/perl";
      libPrefix = "lib/perl5/site_perl";

      perlOnBuild = perlOnBuildForHost.override {
        inherit overrides;
        self = perlOnBuild;
      };

      pkgs = perlPackages // (overrides pkgs);
      withPackages = f: buildEnv.override { extraLibs = f pkgs; };
    };

in
rec {
  perl5 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.42.0";
    self = perl5;
    sha256 = "sha256-4JPvGE1/mhuXl+JGUpb1VRCtttq4hCsMPtUzKWYwltw=";
  };
}
