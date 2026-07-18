{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "pinniped";
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "vmware-tanzu";
    repo = "pinniped";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-C7N6iPD4caTUXR6gB+9sdfBlWyT1tfE8KwE5WaiUdQM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-B94/SR2OVsxDs9+MaivxPBMQsNWFwAEwuDT7xvWN8vg=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pinniped \
      --bash <($out/bin/pinniped completion bash) \
      --fish <($out/bin/pinniped completion fish) \
      --zsh <($out/bin/pinniped completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = "cmd/pinniped";

  meta = {
    description = "Tool to securely log in to your Kubernetes clusters";
    homepage = "https://pinniped.dev/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bpaulin ];
    mainProgram = "pinniped";
  };
})
