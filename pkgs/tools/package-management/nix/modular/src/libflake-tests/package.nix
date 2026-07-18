{
  lib,
  stdenv,
  buildPackages,
  gtest,
  mkMesonExecutable,
  nix-expr-test-support,
  nix-flake,
  nix-flake-c,
  rapidcheck,
  resolvePath,
  runCommand,
  # Configuration Options
  version,
  writableTmpDirAsHomeHook,
}:

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix-flake-tests";

  buildInputs = [
    nix-flake
    nix-flake-c
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
            buildInputs = [ writableTmpDirAsHomeHook ];
            meta.broken = !stdenv.hostPlatform.emulatorAvailable buildPackages;
          }
          ''
            export _NIX_TEST_UNIT_DATA=${resolvePath ./data}
            export NIX_CONFIG="extra-experimental-features = flakes"
            ${stdenv.hostPlatform.emulator buildPackages} ${lib.getExe finalAttrs.finalPackage}
            touch $out
          '';
    };
  };

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = finalAttrs.pname + stdenv.hostPlatform.extensions.executable;
  };

})
