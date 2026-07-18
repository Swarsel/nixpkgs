{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "popeye";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "derailed";
    repo = "popeye";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-CbVYQIE7kjUah+SDEjs5Qz+n4+f3HriQNxYPqDcdr/I=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-Xhn1iOqzCY8fW2lODXwqY4XQZTAPWXaZ0XM5j02bnCs=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd popeye \
      --bash <($out/bin/popeye completion bash) \
      --fish <($out/bin/popeye completion fish) \
      --zsh <($out/bin/popeye completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/popeye version | grep ${finalAttrs.version} > /dev/null
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/derailed/popeye/cmd.version=${finalAttrs.version}"
    "-X github.com/derailed/popeye/cmd.commit=${finalAttrs.version}"
  ];

  meta = {
    description = "Kubernetes cluster resource sanitizer";
    homepage = "https://github.com/derailed/popeye";
    changelog = "https://github.com/derailed/popeye/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "popeye";
  };
})
