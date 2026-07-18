{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  nodejs,
  rustPlatform,
  testers,
  usage,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "usage";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "usage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fqBcdbhoFOnlPqRSSaKPhG6IYilQHvwjgUGEkwQfBQY=";
  };

  postPatch = ''
    substituteInPlace ./examples/*.sh \
      --replace-fail '/usr/bin/env -S usage' "$(pwd)/target/${stdenv.targetPlatform.rust.rustcTargetSpec}/release/usage"
  '';

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-0j17jlqEy+zbtaIS+pKZKE73j/QMaAvEExoS2TTunEs=";

  nativeCheckInputs = [
    # for some tests
    nodejs
  ];

  checkFlags = [
    # has --include-bash-completion-lib so requires external lib downloaded on runtime
    "--skip=test_bash_completion_init_integration"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd usage \
      --bash <($out/bin/usage --completions bash) \
      --fish <($out/bin/usage --completions fish) \
      --zsh <($out/bin/usage --completions zsh)
  '';

  passthru = {
    tests.version = testers.testVersion { package = usage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Specification for CLIs";
    homepage = "https://usage.jdx.dev";
    changelog = "https://github.com/jdx/usage/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ konradmalik ];
    mainProgram = "usage";
  };
})
