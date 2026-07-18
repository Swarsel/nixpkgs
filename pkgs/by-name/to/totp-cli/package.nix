{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "totp-cli";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "yitsushi";
    repo = "totp-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JPS4LXEgFM+RJhJG9w/SmEYmq6kILie139UrFGyZ2q0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-GulRmDKatbu4N29Th4rUiVSvvg4hhepyx5X8TLLJ9kQ=";

  postInstall = ''
    installShellCompletion --bash autocomplete/bash_autocomplete
    installShellCompletion --zsh autocomplete/zsh_autocomplete
  '';

  meta = {
    description = "Authy/Google Authenticator like TOTP CLI tool written in Go";
    homepage = "https://yitsushi.github.io/totp-cli/";
    changelog = "https://github.com/yitsushi/totp-cli/releases/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    mainProgram = "totp-cli";
  };
})
