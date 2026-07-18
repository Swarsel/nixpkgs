{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "air-formatter";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "air";
    tag = finalAttrs.version;
    hash = "sha256-u0icSo6aW6tLgY57RPAoVte5Awn16FLIvZEeeYNr5fk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-51xkTVs6j7n0os5wHWxpFC/uLHm3tz+SiWUHsd+bNRw=";

  # TODO: Upstream also provides Elvish and PowerShell completions,
  # but `installShellCompletion` only has support for Bash, Zsh and Fish at the moment.
  postInstall = ''
    installShellCompletion --cmd air-formatter \
      --bash <($out/bin/air generate-shell-completion bash) \
      --fish <($out/bin/air generate-shell-completion fish) \
      --zsh  <($out/bin/air generate-shell-completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  cargoBuildFlags = [ "--package=air" ];
  useNextest = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extremely fast R code formatter";
    homepage = "https://posit-dev.github.io/air";
    changelog = "https://github.com/posit-dev/air/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kupac ];
    mainProgram = "air";
  };
})
