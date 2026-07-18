{
  lib,
  stdenv,
  buildPackages,
  gtest,
  libgit2,
  mkMesonExecutable,
  nix-fetchers,
  nix-fetchers-c,
  nix-store-test-support,
  rapidcheck,
  resolvePath,
  runCommand,
  # Configuration Options
  version,
  writableTmpDirAsHomeHook,
}:

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix-fetchers-tests";

  buildInputs = [
    nix-fetchers
    nix-store-test-support
    rapidcheck
    gtest
  ]
  ++ lib.optionals (lib.versionAtLeast version "2.29pre") [
    nix-fetchers-c
  ]
  ++ lib.optionals (lib.versionAtLeast version "2.27") [
    libgit2
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
