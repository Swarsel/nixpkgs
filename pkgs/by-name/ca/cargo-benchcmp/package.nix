{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  replaceVars,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-benchcmp";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "cargo-benchcmp";
    tag = finalAttrs.version;
    hash = "sha256-J8KFI0V/mOhUlYtVnFAQgPIpXL9/dLhOFxSly4bR00I=";
  };

  patches = [
    # patch the binary path so tests can find the binary when `--target` is present
    (replaceVars ./fix-test-binary-path.patch {
      shortTarget = stdenv.hostPlatform.rust.rustcTarget;
    })
  ];

  cargoHash = "sha256-Dpn3MbU56zX4vibG0pw5LuQEwvC6Uqzse1GCRHWyAEw=";

  checkFlags = [
    # thread 'different_input_colored' panicked at 'assertion failed: `(left == right)`
    "--skip=different_input_colored"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Small utility to compare Rust micro-benchmarks";
    homepage = "https://github.com/BurntSushi/cargo-benchcmp";

    license = with lib.licenses; [
      mit
      unlicense
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "cargo-benchcmp";
  };
})
