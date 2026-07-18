{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "sqlc";
  version = "1.31.1";

  src = fetchFromGitHub {
    owner = "sqlc-dev";
    repo = "sqlc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/skb7p3s9TaQE699UCprk1D6S+G/T8Ek9/ADOtS/n44=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-+kSAupLQwTzJdgnhlqulEtRcDj9gqSq8uTnWNyDLZew=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sqlc \
      --bash <($out/bin/sqlc completion bash) \
      --fish <($out/bin/sqlc completion fish) \
      --zsh <($out/bin/sqlc completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;
  subPackages = [ "cmd/sqlc" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Generate type-safe code from SQL";
    homepage = "https://sqlc.dev/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "sqlc";
  };
})
