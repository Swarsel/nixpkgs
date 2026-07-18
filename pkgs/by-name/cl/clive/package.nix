{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  ttyd,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "clive";
  version = "0.12.17";

  src = fetchFromGitHub {
    owner = "koki-develop";
    repo = "clive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-omHxs2hTzjddelPkJWj2sVmK9nI5bCELUS8EmEH7JXM=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = [ ttyd ];
  vendorHash = "sha256-M3cU2051lOzm9hXuVwC1eFI8Ftpmk32h/98dHUkRfts=";

  postInstall = ''
    wrapProgram $out/bin/clive --prefix PATH : ${ttyd}/bin
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd clive \
      --bash <($out/bin/clive completion bash) \
      --fish <($out/bin/clive completion fish) \
      --zsh <($out/bin/clive completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X github.com/koki-develop/clive/cmd.version=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automates terminal operations";
    homepage = "https://github.com/koki-develop/clive";
    changelog = "https://github.com/koki-develop/clive/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misilelab ];
    mainProgram = "clive";
  };
})
