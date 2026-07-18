{
  lib,
  stdenv,
  rustPlatform,
  rustc,
}:

rustPlatform.buildRustPackage {
  inherit (rustc) version src;
  pname = "clippy";
  buildInputs = [ rustc.llvm ];
  # fixes: error: the option `Z` is only accepted on the nightly compiler
  env.RUSTC_BOOTSTRAP = 1;
  # Without disabling the test the build fails with:
  # error: failed to run custom build command for `rustc_llvm v0.0.0
  #   (/private/tmp/nix-build-clippy-1.36.0.drv-0/rustc-1.36.0-src/src/librustc_llvm)
  doCheck = false;

  # Clippy uses the rustc_driver and std private libraries, and Rust's build process forces them to have
  # an install name of `@rpath/...` [0] [1] instead of the standard on macOS, which is an absolute path
  # to itself.
  #
  # [0]: https://github.com/rust-lang/rust/blob/f77f4d55bdf9d8955d3292f709bd9830c2fdeca5/src/bootstrap/builder.rs#L1543
  # [1]: https://github.com/rust-lang/rust/blob/f77f4d55bdf9d8955d3292f709bd9830c2fdeca5/compiler/rustc_codegen_ssa/src/back/linker.rs#L323-L331
  preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath "${rustc.unwrapped}/lib" "$out/bin/clippy-driver"
    install_name_tool -add_rpath "${rustc.unwrapped}/lib" "$out/bin/cargo-clippy"
  '';

  buildAndTestSubdir = "src/tools/clippy";
  # the rust source tarball already has all the dependencies vendored, no need to fetch them again
  cargoVendorDir = "vendor";
  # changes hash of vendor directory otherwise
  dontUpdateAutotoolsGnuConfigScripts = true;
  separateDebugInfo = true;

  meta = {
    description = "Bunch of lints to catch common mistakes and improve your Rust code";
    homepage = "https://rust-lang.github.io/rust-clippy/";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ basvandijk ];
    platforms = lib.platforms.unix;
    mainProgram = "cargo-clippy";
    teams = [ lib.teams.rust ];
  };
}
