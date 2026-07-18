{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-statuses";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "bircni";
    repo = "git-statuses";
    tag = finalAttrs.version;
    hash = "sha256-p200nv8H/tuO48ZBsTQvM0JBGN4Yu58kXLhYl8AJxfc=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-MJekW/AzVe1dCr5La4+FKBeyGFAjN0fCBUiGnMoAtdI=";
  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd git-statuses \
      --bash <($out/bin/git-statuses --completions bash) \
      --fish <($out/bin/git-statuses --completions fish) \
      --zsh <($out/bin/git-statuses --completions zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    git
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool to display the status of multiple Git repositories in a clear, tabular format";
    homepage = "https://github.com/bircni/git-statuses";
    changelog = "https://github.com/bircni/git-statuses/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
    mainProgram = "git-statuses";
  };
})
