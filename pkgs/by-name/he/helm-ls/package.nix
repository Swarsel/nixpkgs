{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  helm-ls,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "helm-ls";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "mrjosh";
    repo = "helm-ls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4M2o/M8mnO+9QwsjsGahY3i/pwtsNdCMCn5oCFGm0aI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-4zQy7PFC41iBVKvDRaW2zUnUzCSQmjAmyKsdnLDUHJ8=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    mv $out/bin/helm-ls $out/bin/helm_ls
    installShellCompletion --cmd helm_ls \
      --bash <($out/bin/helm_ls completion bash) \
      --fish <($out/bin/helm_ls completion fish) \
      --zsh <($out/bin/helm_ls completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "helm_ls version";
    package = helm-ls;
  };

  meta = {
    description = "Language server for Helm";
    homepage = "https://github.com/mrjosh/helm-ls";
    changelog = "https://github.com/mrjosh/helm-ls/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stehessel ];
    mainProgram = "helm_ls";
  };
})
