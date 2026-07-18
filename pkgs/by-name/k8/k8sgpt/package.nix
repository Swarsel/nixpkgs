{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "k8sgpt";
  version = "0.4.36";

  src = fetchFromGitHub {
    owner = "k8sgpt-ai";
    repo = "k8sgpt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J8imL+Rkp7/0xMppjMSXFdLTH3CwLvS1+Tbt6CWI6SQ=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-XLlBDFbvjr+Bun9V36MYwknz7SPw39ovd0b9gCht7L8=";
  # https://nixos.org/manual/nixpkgs/stable/#var-go-CGO_ENABLED
  env.CGO_ENABLED = 0;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd k8sgpt \
      --bash <($out/bin/k8sgpt completion bash) \
      --zsh <($out/bin/k8sgpt completion zsh) \
      --fish <($out/bin/k8sgpt completion fish)
  '';

  # https://nixos.org/manual/nixpkgs/stable/#ssec-skip-go-tests
  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=1970-01-01-00:00:01"
  ];

  meta = {
    description = "Giving Kubernetes Superpowers to everyone";
    homepage = "https://k8sgpt.ai";
    changelog = "https://github.com/k8sgpt-ai/k8sgpt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      developer-guy
      kranurag7
      mrgiles
    ];

    mainProgram = "k8sgpt";
  };
})
