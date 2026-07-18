{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "kubernetes-polaris";
  version = "10.1.7";

  src = fetchFromGitHub {
    owner = "FairwindsOps";
    repo = "polaris";
    rev = finalAttrs.version;
    sha256 = "sha256-0uz5Q7RvPTDIo6R6YIsK2jr1UIq1OJN0+IjyWciyA28=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-M+/Jtw+SiLY+G3UKtRCFX1j6tH35FIQMX33YgacJAec=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd polaris \
      --bash <($out/bin/polaris completion bash) \
      --fish <($out/bin/polaris completion fish) \
      --zsh <($out/bin/polaris completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/polaris help
    $out/bin/polaris version | grep 'Polaris version:${finalAttrs.version}'

    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.Commit=${finalAttrs.version}"
  ];

  meta = {
    description = "Validate and remediate Kubernetes resources to ensure configuration best practices are followed";
    homepage = "https://www.fairwinds.com/polaris";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ longer ];
    mainProgram = "polaris";
  };
})
