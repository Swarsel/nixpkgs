{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "worktrunk";
  version = "0.66.0";

  src = fetchFromGitHub {
    owner = "max-sixty";
    repo = "worktrunk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GKXTEzCya5aOh02O3yoEdA4RS/GibiHZu+wXq7rrOV0=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-MjRi4WK+afrShCLXEp7pWhDiAyjKPbtqHjVIOtI3LVI=";
  # vergen-gitcl calls `git describe` at build time; VERGEN_IDEMPOTENT makes it
  # fall back gracefully when no git history is available (Nix sandbox).
  env.VERGEN_IDEMPOTENT = "1";
  nativeCheckInputs = [ gitMinimal ];

  checkFlags = [
    # Expects `which` on PATH
    "--skip=output::commit_generation::tests::test_command_exists_known_command"
    # Integration tests use insta snapshots with environment-specific paths
    "--skip=integration_tests::"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # wt reads config from $HOME; provide a throwaway dir so it doesn't fail.
    export HOME="$(mktemp -d)"

    installShellCompletion --cmd wt \
      --bash <($out/bin/wt config shell completions bash) \
      --fish <($out/bin/wt config shell completions fish) \
      --nushell <($out/bin/wt config shell completions nu) \
      --zsh <($out/bin/wt config shell completions zsh)

    # -L dereferences symlinks (e.g. skills/worktrunk/reference/README.md → repo
    # root), so no dangling symlinks end up in $out.
    cp -RL ${finalAttrs.src}/skills $out/
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "--package=worktrunk" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Git worktree manager for parallel AI agent workflows";

    longDescription = ''
      worktrunk wraps git worktree with a simpler interface and integrates with
      AI coding tools like Claude Code, Cursor, and Aider.
    '';

    homepage = "https://worktrunk.dev/";
    changelog = "https://github.com/max-sixty/worktrunk/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      siriobalmelli
      DuskyElf
    ];

    platforms = lib.platforms.unix;
    mainProgram = "wt";
  };
})
