{
  lib,
  stdenv,
  buildPackages,
  filesetToSource,
  gtest,
  mkMesonExecutable,
  nix-store,
  nix-store-c,
  nix-store-test-support,
  openssl,
  rapidcheck,
  runCommand,
  sqlite,
  # Configuration Options
  version,
  writableTmpDirAsHomeHook,
}:

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix-store-tests";

  buildInputs = [
    sqlite
    rapidcheck
    gtest

    nix-store
    nix-store-c
    nix-store-test-support
  ];

  mesonFlags = [
  ];

  excludedTestPatterns = lib.optionals (lib.versionOlder finalAttrs.version "2.31") [
    "nix_api_util_context.nix_store_real_path_binary_cache"
  ];

  workDir = ./.;

  passthru = {
    tests = {
      run =
        let
          # Some data is shared with the functional tests: they create it,
          # we consume it.
          data = filesetToSource {
            fileset = lib.fileset.unions [
              ./data
              ../../tests/functional/derivation
            ];

            root = ../..;
          };
        in
        runCommand "${finalAttrs.pname}-run"
          {
            nativeBuildInputs = [
              writableTmpDirAsHomeHook
            ]
            ++ lib.optional (lib.versionAtLeast version "2.34pre") (lib.getBin openssl);

            meta.broken = !stdenv.hostPlatform.emulatorAvailable buildPackages;
          }
          ''
            export _NIX_TEST_UNIT_DATA=${data + "/src/libstore-tests/data"}
            export NIX_REMOTE=$HOME/store
            ${stdenv.hostPlatform.emulator buildPackages} ${lib.getExe finalAttrs.finalPackage} \
              --gtest_filter=-${lib.concatStringsSep ":" finalAttrs.excludedTestPatterns}
            touch $out
          '';
    };
  };

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = finalAttrs.pname + stdenv.hostPlatform.extensions.executable;
  };

})
