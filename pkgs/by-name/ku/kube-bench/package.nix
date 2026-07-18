{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kube-bench";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "kube-bench";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PxCybf+lNo+ys8t8dTLZUVaovsg63DR3eeiv71w+N4M=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-GpUCOd2FR+D4hKdvrulfw4HknohfWnsWzdJI6tb0nhA=";

  postInstall = ''
    mkdir -p $out/share/kube-bench/
    mv ./cfg $out/share/kube-bench/

    installShellCompletion --cmd kube-bench \
      --bash <($out/bin/kube-bench completion bash) \
      --fish <($out/bin/kube-bench completion fish) \
      --zsh <($out/bin/kube-bench completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true; # required for tests

  ldflags = [
    "-s"
    "-w"
    "-X github.com/aquasecurity/kube-bench/cmd.KubeBenchVersion=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Checks whether Kubernetes is deployed according to security best practices as defined in the CIS Kubernetes Benchmark";
    homepage = "https://github.com/aquasecurity/kube-bench";
    changelog = "https://github.com/aquasecurity/kube-bench/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "kube-bench";
  };
})
