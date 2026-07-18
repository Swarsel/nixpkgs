{
  lib,
  stdenv,
  buildPackages,
  gtest,
  mkMesonExecutable,
  nix-expr,
  nix-expr-c,
  nix-expr-test-support,
  rapidcheck,
  resolvePath,
  runCommand,
  # Configuration Options
  version,
}:

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix-expr-tests";

  buildInputs = [
    nix-expr
    nix-expr-c
    nix-expr-test-support
    rapidcheck
    gtest
  ];

  mesonFlags = [
  ];

  workDir = ./.;

  passthru = {
    tests = {
      run =
        runCommand "${finalAttrs.pname}-run"
          {
            meta.broken = !stdenv.hostPlatform.emulatorAvailable buildPackages;
          }
          (
            lib.optionalString stdenv.hostPlatform.isWindows ''
              export HOME="$PWD/home-dir"
              mkdir -p "$HOME"
            ''
            + ''
              export _NIX_TEST_UNIT_DATA=${resolvePath ./data}
              ${stdenv.hostPlatform.emulator buildPackages} ${lib.getExe finalAttrs.finalPackage}
              touch $out
            ''
          );
    };
  };

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = finalAttrs.pname + stdenv.hostPlatform.extensions.executable;
  };

})
