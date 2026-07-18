{
  bootstrapHashes,
  bootstrapVersion,
  cargo-auditable,
  llvmPackages, # Exposed through rustc for LTO in Firefox
  llvmShared,
  llvmSharedForBuild,
  llvmSharedForHost,
  llvmSharedForTarget,
  rustcSha256,
  rustcVersion,
  selectRustPackage,
  enableRustcDev ? true,
  rustcPatches ? [ ],
}:
{
  lib,
  stdenv,
  callPackage,
  makeRustPlatform,
  newScope,
  pkgsBuildBuild,
  pkgsBuildHost,
  pkgsBuildTarget,
  pkgsTargetTarget,
  wrapRustcWith,
}:

let
  # Use `import` to make sure no packages sneak in here.
  lib' = import ../../../build-support/rust/lib {
    inherit
      lib
      stdenv
      pkgsBuildHost
      pkgsBuildTarget
      pkgsTargetTarget
      ;
  };
  # Allow faster cross compiler generation by reusing Build artifacts
  fastCross =
    (stdenv.buildPlatform == stdenv.hostPlatform) && (stdenv.hostPlatform != stdenv.targetPlatform);
in
{
  # Backwards compat before `lib` was factored out.
  inherit (lib')
    toTargetArch
    toTargetOs
    toRustTarget
    toRustTargetSpec
    IsNoStdTarget
    toRustTargetForUseInEnvVars
    envVars
    ;

  lib = lib';

  # This just contains tools for now. But it would conceivably contain
  # libraries too, say if we picked some default/recommended versions to build
  # by Hydra.
  #
  # In the end game, rustc, the rust standard library (`core`, `std`, etc.),
  # and cargo would themselves be built with `buildRustCreate` like
  # everything else. Tools and `build.rs` and procedural macro dependencies
  # would be taken from `buildRustPackages` (and `bootstrapRustPackages` for
  # anything provided prebuilt or their build-time dependencies to break
  # cycles / purify builds). In this way, nixpkgs would be in control of all
  # bootstrapping.
  packages = {
    prebuilt = callPackage ./bootstrap.nix {
      version = bootstrapVersion;
      hashes = bootstrapHashes;
    };

    stable = lib.makeScope newScope (
      self:
      let
        # Like `buildRustPackages`, but may also contain prebuilt binaries to
        # break cycle. Just like `bootstrapTools` for nixpkgs as a whole,
        # nothing in the final package set should refer to this.
        bootstrapRustPackages =
          if fastCross then
            pkgsBuildBuild.rustPackages
          else
            self.buildRustPackages.overrideScope (
              _: _:
              lib.optionalAttrs (stdenv.buildPlatform == stdenv.hostPlatform)
                (selectRustPackage pkgsBuildHost).packages.prebuilt
            );
        bootRustPlatform = makeRustPlatform bootstrapRustPackages;
      in
      {
        inherit cargo-auditable;
        # Packages suitable for build-time, e.g. `build.rs`-type stuff.
        buildRustPackages = (selectRustPackage pkgsBuildHost).packages.stable;

        cargo =
          if (!fastCross) then
            self.callPackage ./cargo.nix {
              # Use boot package set to break cycle
              rustPlatform = bootRustPlatform;
            }
          else
            self.callPackage ./cargo_cross.nix { };

        cargo-auditable-cargo-wrapper = self.callPackage ./cargo-auditable-cargo-wrapper.nix { };
        clippy = if !fastCross then self.clippy-unwrapped else self.callPackage ./clippy-wrapper.nix { };
        clippy-unwrapped = self.callPackage ./clippy.nix { };
        # Analogous to stdenv
        rustPlatform = makeRustPlatform self.buildRustPackages;

        rustc = wrapRustcWith {
          inherit (self) rustc-unwrapped;
          sysroot = if fastCross then self.rustc-unwrapped else null;
        };

        rustc-unwrapped = self.callPackage ./rustc.nix {
          inherit enableRustcDev;

          inherit
            llvmShared
            llvmSharedForBuild
            llvmSharedForHost
            llvmSharedForTarget
            llvmPackages
            fastCross
            ;

          # Use boot package set to break cycle
          inherit (bootstrapRustPackages) cargo rustc rustfmt;
          version = rustcVersion;
          patches = rustcPatches;
          sha256 = rustcSha256;
        };

        rustfmt = self.callPackage ./rustfmt.nix {
          inherit (self.buildRustPackages) rustc;
        };
      }
    );
  };
}
