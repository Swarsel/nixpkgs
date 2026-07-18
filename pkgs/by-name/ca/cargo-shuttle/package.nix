{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-shuttle";
  version = "0.57.3";

  src = fetchFromGitHub {
    owner = "shuttle-hq";
    repo = "shuttle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qPevl75wmOYVhTgMiJOi+6j8LBWKzM7HPhd5mdf2B+8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    zlib
  ];

  cargoHash = "sha256-H2fy2NQvLQEzbQik+nrUvoYZaWQRXX6PpO9LcYfiF2I=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "-p"
    "cargo-shuttle"
  ];

  cargoTestFlags = finalAttrs.cargoBuildFlags ++ [
    # other tests are failing for different reasons
    "init::shuttle_init_tests::"
  ];

  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo command for the shuttle platform";
    homepage = "https://shuttle.rs";
    changelog = "https://github.com/shuttle-hq/shuttle/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "cargo-shuttle";
  };
})
