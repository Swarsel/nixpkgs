{
  lib,
  stdenv,
  fetchFromGitHub,
  aws-sdk-cpp,
  boehmgc,
  callPackage,
  clangStdenv,
  colmena,
  config,
  editline,
  fetchFromGitea,
  fetchgit,
  fetchpatch,
  fetchpatch2,
  generateSplicesForMkScope,
  haskell,
  makeScopeWithSplicing',
  ncurses,
  nil,
  nix-direnv,
  nix-du,
  nix-fast-build,
  nix-init,
  nix-serve-ng,
  nix-update,
  nixos-anywhere,
  nixos-rebuild-ng,
  nixpkgs-review,
  nixpkgs-reviewFull,
  nurl,
  rustPlatform,
  confDir ? "/etc",
  stateDir ? "/nix/var",
  storeDir ? "/nix/store",
}:
let
  lixMdbookPatch = fetchpatch2 {
    excludes = [ "package.nix" ];
    hash = "sha256-uu/SIG8fgVVWhsGxmszTPHwe4SQtLgbxdShOMKbeg2w=";
    name = "lix-mdbook-0.5-support.patch";
    url = "https://git.lix.systems/lix-project/lix/commit/54df89f601b3b4502a5c99173c9563495265d7e7.patch";
  };
  makeLixScope =
    {
      attrName,
      lix-args,
      # Starting with 2.93, `nix-eval-jobs` lives in the `lix` repository.
      nix-eval-jobs-args ? { inherit (lix-args) version src; },
    }:
    let
      # GCC 13.2 is known to miscompile Lix coroutines (introduced in 2.92).
      lixStdenv = if lib.versionAtLeast lix-args.version "2.92" then clangStdenv else stdenv;
    in
    makeScopeWithSplicing' {
      f =
        self:
        lib.recurseIntoAttrs {
          inherit
            storeDir
            stateDir
            confDir
            ;

          aws-sdk-cpp =
            (aws-sdk-cpp.override {
              apis = [
                "s3"
                "transfer"
              ];

              customMemoryManagement = false;
            }).overrideAttrs
              {
                # only a stripped down version is build which takes a lot less resources to build
                requiredSystemFeatures = [ ];
              };

          boehmgc = boehmgc.override {
            enableLargeConfig = true;
            initialMarkStackSize = 1048576;
          };

          colmena = colmena.override {
            inherit (self) nix-eval-jobs;
            nix = self.lix;
          };

          editline = editline.override {
            inherit ncurses;
            enableTermcap = true;
          };

          # NOTE: The `common-*.nix` helpers contain a top-level function which
          # takes the Lix source to build and version information. We use the
          # outer `callPackage` for that.
          #
          # That *returns* another function which takes the actual build
          # dependencies, and that uses the new scope's `self.callPackage` so
          # that `nix-eval-jobs` can be built against the correct `lix` version.
          lix = self.callPackage (callPackage ./common-lix.nix lix-args) {
            stdenv = lixStdenv;
          };

          nil = nil.override {
            nix = self.lix;
          };

          nix-direnv = nix-direnv.override {
            nix = self.lix;
          };

          nix-du = nix-du.override {
            nix = self.lix;
          };

          nix-eval-jobs = self.callPackage (callPackage ./common-nix-eval-jobs.nix nix-eval-jobs-args) {
            stdenv = lixStdenv;
          };

          nix-fast-build = nix-fast-build.override {
            inherit (self) nix-eval-jobs;
          };

          nix-init = nix-init.override {
            inherit (self) nurl;
            nix = self.lix;
          };

          nix-serve-ng = lib.pipe (nix-serve-ng.override { nix = self.lix; }) [
            (haskell.lib.compose.enableCabalFlag "lix")
            (haskell.lib.compose.overrideCabal (drv: {
              # Resetting (previous) broken flag since it may be related to C++ Nix
              broken = false;
            }))
          ];

          nix-update = nix-update.override {
            inherit (self) nixpkgs-review;
            nix = self.lix;
          };

          nixos-anywhere = nixos-anywhere.override {
            nix = self.lix;
          };

          nixos-rebuild-ng = nixos-rebuild-ng.override {
            nix = self.lix;
          };

          nixpkgs-review = nixpkgs-review.override {
            nix = self.lix;
          };

          # surprisingly nixpkgs-reviewFull.override { nix = self.lix; }
          # doesn't work, as the way nix-reviewFull is defined uses callPackage
          # which does it's own makeOverridable and hides the .override
          # from the derivation.
          nixpkgs-reviewFull = nixpkgs-reviewFull.override {
            nixpkgs-review = self.nixpkgs-review;
          };

          nurl = nurl.override {
            nix = self.lix;
          };
        };

      otherSplices = generateSplicesForMkScope [
        "lixPackageSets"
        attrName
      ];
    };

  removedMessage = version: ''
    Lix ${version} is now removed from this revision of Nixpkgs. Consider upgrading to stable or the latest version.

          If you notice a problem while upgrading disrupting your workflows which did not occur in version ${version}, please reach out to the Lix team.
  '';
in
lib.makeExtensible (
  self:
  {
    inherit makeLixScope;

    git = self.makeLixScope {
      attrName = "git";

      lix-args = rec {
        version = "2.96.0-pre-20260408_${builtins.substring 0 12 src.rev}";

        src = fetchFromGitea {
          owner = "lix-project";
          repo = "lix";
          rev = "bc9fb560ac2d36cd317a856ee96785ea2055fbff";
          hash = "sha256-bONRPjhk5OZdnkQZexZNJzlvwIPg31Gy7fNiwGoX3BQ=";
          domain = "git.lix.systems";
        };

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-a5XtutX+NS4wOqxeqbscWZMs99teKick5+cQfbCRGxQ=";
          name = "lix-${version}";
        };
      };
    };

    latest = self.lix_2_95;

    lix_2_94 = self.makeLixScope {
      attrName = "lix_2_94";

      lix-args = rec {
        version = "2.94.2";

        src = fetchFromGitea {
          owner = "lix-project";
          repo = "lix";
          rev = version;
          hash = "sha256-Nmqsl/YCnBW5U3TUfFWHGVUbyS2/Ll655BAE3qZilC4=";
          domain = "git.lix.systems";
        };

        patches = [
          lixMdbookPatch
        ];

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-APm8m6SVEAO17BBCka13u85/87Bj+LePP7Y3zHA3Mpg=";
          name = "lix-${version}";
        };
      };
    };

    lix_2_95 = self.makeLixScope {
      attrName = "lix_2_95";

      lix-args = rec {
        version = "2.95.2";

        src = fetchFromGitea {
          owner = "lix-project";
          repo = "lix";
          rev = version;
          hash = "sha256-nFxJMIdcGTI9NiHAa5HZ2BmcGFLwC2pTq+V4Gjc499I=";
          domain = "git.lix.systems";
        };

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-a5XtutX+NS4wOqxeqbscWZMs99teKick5+cQfbCRGxQ=";
          name = "lix-${version}";
        };
      };
    };

    # Previously, `nix-eval-jobs` was not packaged here, so we export an
    # attribute with the previously-expected structure for compatibility. This
    # is also available (for now) as `pkgs.lixVersions`.
    renamedDeprecatedLixVersions =
      let
        mkAlias =
          version:
          lib.warnOnInstantiate "'lixVersions.${version}' has been renamed to 'lixPackageSets.${version}.lix'"
            self.${version}.lix;
      in
      lib.dontRecurseIntoAttrs {
        latest = mkAlias "latest";
        # NOTE: Do not add new versions of Lix here.
        stable = mkAlias "stable";
      }
      // lib.optionalAttrs config.allowAliases {
        # Legacy removed versions. We keep their aliases until the lixPackageSets one is dropped.
        lix_2_90 = mkAlias "lix_2_90";
        lix_2_91 = mkAlias "lix_2_91";
      };

    stable = self.lix_2_95;
  }
  // lib.optionalAttrs config.allowAliases {
    # Removed versions.
    # When removing a version, add an alias with a date attached to it so we can clean it up after a while.
    lix_2_90 = throw (removedMessage "2.90"); # added in 2025-09-11
    lix_2_91 = throw (removedMessage "2.91"); # added in 2025-09-11
    lix_2_92 = throw (removedMessage "2.92"); # added in 2025-09-11
    lix_2_93 = throw (removedMessage "2.93"); # added in 2026-04-19
  }
)
