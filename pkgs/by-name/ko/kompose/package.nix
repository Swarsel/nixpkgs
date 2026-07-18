{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  git,
  installShellFiles,
  kompose,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kompose";
  version = "1.38.0";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kompose";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d2rUkLGU9s2+LTBI3N7WZx1ByDv05DOUq/2OCQViiOM=";
  };

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  vendorHash = "sha256-53G3nkz+uTwpgiZZFfmrv7Wv6d8iVm6xVyRuxjKA5Po=";
  checkFlags = [ "-short" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <($out/bin/${finalAttrs.meta.mainProgram} completion bash) \
      --zsh <($out/bin/${finalAttrs.meta.mainProgram} completion zsh) \
      --fish <($out/bin/${finalAttrs.meta.mainProgram} completion fish)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    command = "kompose version";
    package = kompose;
  };

  meta = {
    description = "Tool to help users who are familiar with docker-compose move to Kubernetes";
    homepage = "https://kompose.io";
    changelog = "https://github.com/kubernetes/kompose/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      thpham
      vdemeester
    ];

    mainProgram = "kompose";
  };
})
