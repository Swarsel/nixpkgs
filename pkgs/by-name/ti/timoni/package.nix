{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "timoni";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "stefanprodan";
    repo = "timoni";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MCqpap94d1+4TJmn7JgYcNgZaqqB2c+G2w8BdNZG5ac=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-r4Q1kXbDfYjRilmRmtjVW9rb9YfQOFPg51x8ZHSRVpk=";
  # Some tests require running Kubernetes instance
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd timoni \
    --bash <($out/bin/timoni completion bash) \
    --fish <($out/bin/timoni completion fish) \
    --zsh <($out/bin/timoni completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X main.VERSION=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/timoni" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Package manager for Kubernetes, powered by CUE and inspired by Helm";
    homepage = "https://timoni.sh";
    changelog = "https://github.com/stefanprodan/timoni/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ votava ];
    mainProgram = "timoni";
  };
})
