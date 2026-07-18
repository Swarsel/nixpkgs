{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  # nativeBuildInputs
  installShellFiles,
  nix-update-script,
  # buildInputs
  rust-jemalloc-sys,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ty";
  version = "0.0.56";

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "ty";
    tag = finalAttrs.version;
    hash = "sha256-H5Tin3+OFSmlC2b86gPISE0ZK6+vR+ijYtJBzeyBgL4=";
    fetchSubmodules = true;
  };

  # For Darwin platforms, remove the integration test for file notifications,
  # as these tests fail in its sandboxes.
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    rm ${finalAttrs.cargoRoot}/crates/ty/tests/file_watching.rs
  '';

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ rust-jemalloc-sys ];
  cargoHash = "sha256-suXPAZAQ4dddcHBwmdrpC4cUEs7CgTmW9Bn/v9Roe0U=";

  checkFlags = [
    # Flaky:
    # called `Result::unwrap()` on an `Err` value: Os { code: 26, kind: ExecutableFileBusy, message: "Text file busy" }
    "--skip=python_environment::ty_environment_and_active_environment"
    "--skip=python_environment::ty_environment_and_discovered_venv"
    "--skip=python_environment::ty_environment_is_only_environment"
    "--skip=python_environment::ty_environment_is_system_not_virtual"
    "--skip=python_environment::ty_system_environment_and_local_venv"

    # flaky: unmatched assertion: revealed: Literal[1]
    "--skip=mdtest::generics/pep695/functions.md"
  ];

  # `ty`'s tests use `insta-cmd`, which depends on the structure of the `target/` directory,
  # and also fails to find the environment variable `$CARGO_BIN_EXE_ty`, which leads to tests failing.
  # Instead, we specify the path ourselves and forgo the lookup.
  # As the patches occur solely in test code, they have no effect on the packaged `ty` binary itself.
  #
  # `stdenv.hostPlatform.rust.cargoShortTarget` is taken from `cargoSetupHook`'s `installPhase`,
  # which constructs a path as below to reference the built binary.
  preCheck = ''
    export CARGO_BIN_EXE_ty="$PWD"/target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/ty
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd ty \
        --bash <(${emulator} $out/bin/ty generate-shell-completion bash) \
        --fish <(${emulator} $out/bin/ty generate-shell-completion fish) \
        --zsh <(${emulator} $out/bin/ty generate-shell-completion zsh)
    ''
  );

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoBuildFlags = [ "--package=ty" ];
  cargoRoot = "ruff";

  cargoTestFlags = [
    "--package=ty" # CLI tests; file-watching tests only on Linux platforms
    "--package=ty_python_semantic" # core type checking tests
    "--package=ty_test" # test framework tests
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extremely fast Python type checker and language server, written in Rust";
    homepage = "https://github.com/astral-sh/ty";
    changelog = "https://github.com/astral-sh/ty/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bengsparks
      ddogfoodd
      figsoda
      GaetanLepage
    ];

    mainProgram = "ty";
  };
})
