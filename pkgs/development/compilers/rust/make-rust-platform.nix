{
  lib,
  stdenv,
  buildPackages,
  callPackages,
  cargo-auditable,
  config,
  generateSplicesForMkScope,
  makeScopeWithSplicing',
  runCommand,
}@prev:

{
  stdenv ? prev.stdenv,
  cargo,
  rustc,
  cargo-auditable ? prev.cargo-auditable,
  ...
}:

(makeScopeWithSplicing' {
  f =
    self:
    let
      inherit (self) callPackage;
    in
    {
      # Hooks
      inherit
        (callPackages ../../../build-support/rust/hooks {
          inherit
            stdenv
            ;
        })
        cargoBuildHook
        cargoCheckHook
        cargoInstallHook
        cargoNextestHook
        cargoSetupHook
        maturinBuildHook
        bindgenHook
        ;

      buildRustPackage = callPackage ../../../build-support/rust/build-rust-package {
        inherit
          stdenv
          rustc
          cargo
          cargo-auditable
          ;
      };

      fetchCargoVendor = buildPackages.callPackage ../../../build-support/rust/fetch-cargo-vendor.nix {
        inherit cargo;
      };

      importCargoLock = buildPackages.callPackage ../../../build-support/rust/import-cargo-lock.nix {
        inherit cargo;
      };

      rustLibSrc = callPackage ./rust-lib-src.nix {
        inherit runCommand rustc;
      };

      # Useful when rebuilding std
      # e.g. when building wasm with wasm-pack
      rustVendorSrc = callPackage ./rust-vendor-src.nix {
        inherit runCommand rustc;
      };

      rustcSrc = callPackage ./rust-src.nix {
        inherit runCommand rustc;
      };
    };

  otherSplices = generateSplicesForMkScope "rustPlatform";
})
// lib.optionalAttrs config.allowAliases {
  # Added in 25.05.
  fetchCargoTarball = throw "`rustPlatform.fetchCargoTarball` has been removed in 25.05, use `rustPlatform.fetchCargoVendor` instead";

  rust = {
    cargo = lib.warn "rustPlatform.rust.cargo is deprecated. Use cargo instead." cargo;
    rustc = lib.warn "rustPlatform.rust.rustc is deprecated. Use rustc instead." rustc;
  };
}
