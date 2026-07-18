{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cilium-cli,
  installShellFiles,
  testers,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "cilium-cli";
  version = "0.19.5";

  src = fetchFromGitHub {
    owner = "cilium";
    repo = "cilium-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2MxIqKuuzSEzmhdmWqYxinHKzlP7io7Tw6Ini2Sl3wQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cilium \
      --bash <($out/bin/cilium completion bash) \
      --fish <($out/bin/cilium completion fish) \
      --zsh <($out/bin/cilium completion zsh)
  '';

  # Required to workaround install check error:
  # 2022/06/25 10:36:22 Unable to start gops: mkdir /homeless-shelter: permission denied
  nativeInstallCheckInputs = [ writableTmpDirAsHomeHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/cilium/cilium/cilium-cli/defaults.CLIVersion=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/cilium" ];

  passthru.tests.version = testers.testVersion {
    version = "${finalAttrs.version}";
    command = "cilium version --client";
    package = cilium-cli;
  };

  meta = {
    description = "CLI to install, manage & troubleshoot Kubernetes clusters running Cilium";
    homepage = "https://www.cilium.io/";
    changelog = "https://github.com/cilium/cilium-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      humancalico
      qjoly
      ryan4yin
    ];

    mainProgram = "cilium";
  };
})
