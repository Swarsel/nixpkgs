{
  lib,
  fetchFromGitHub,
  git,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jarl";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "etiennebacher";
    repo = "jarl";
    tag = finalAttrs.version;
    hash = "sha256-MFP1xMNnJ9mfHuUu6hqE9B7nRgI2HfXBpblo3sFnAwo=";
  };

  postPatch = ''
    # Nix sandbox uses build/.tmp as temp dir
    substituteInPlace crates/jarl/tests/integration/helpers/command_ext.rs \
    --replace-fail '(?:/private)?/(?:tmp|var/folders/[^/]+/[^/]+/T)/' \
                   '(?:/nix)?/(?:build)/(?:nix[\-0-9]+/)?'
  '';

  # integrations test require git at build time (jarl >= 0.5.0)
  nativeBuildInputs = [ git ];
  cargoHash = "sha256-Rhv9Wku/bRl28nrXYof+6VAgl2K4ysILRQa1v19r0pU=";

  postInstall = ''
    rm $out/bin/xtask_codegen
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # Don't run integration_tests for jarl-lsp, because it doesn't see
  # the CARGO_BIN_EXE_jarl env var even if exported in preCheck
  cargoTestFlags = [
    "--lib"
    "--bins"
    "--test"
    "integration"
    # "--test integration_tests"
  ];

  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Just another R linter";
    homepage = "https://jarl.etiennebacher.com";
    changelog = "https://jarl.etiennebacher.com/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kupac ];
    mainProgram = "jarl";
  };
})
