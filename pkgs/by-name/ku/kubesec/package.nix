{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "kubesec";
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "controlplaneio";
    repo = "kubesec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4jVRd6XQekL4wMZ+Icoa2DEsTGzBISK2QPO+gu890kA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-6jXGc9tkqRTjzEiug8lGursPm9049THWlk8xY3pyVgo=";
  # Tests wants to download the kubernetes schema for use with kubeval
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kubesec \
      --bash <($out/bin/kubesec completion bash) \
      --fish <($out/bin/kubesec completion fish) \
      --zsh <($out/bin/kubesec completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/kubesec --help
    $out/bin/kubesec version | grep "${finalAttrs.version}"

    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/controlplaneio/kubesec/v${lib.versions.major finalAttrs.version}/cmd.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Security risk analysis tool for Kubernetes resources";
    homepage = "https://github.com/controlplaneio/kubesec";
    changelog = "https://github.com/controlplaneio/kubesec/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];

    maintainers = with lib.maintainers; [
      fab
      jk
    ];

    mainProgram = "kubesec";
  };
})
