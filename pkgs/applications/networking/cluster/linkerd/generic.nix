{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

{
  channel,
  sha256,
  vendorHash,
  version,
}:

buildGoModule rec {
  inherit version vendorHash;
  pname = "linkerd-${channel}";

  src = fetchFromGitHub {
    inherit sha256;
    owner = "linkerd";
    repo = "linkerd2";
    rev = "${channel}-${version}";
  };

  nativeBuildInputs = [ installShellFiles ];

  preBuild = ''
    env GOFLAGS="" go generate ./pkg/charts/static
    env GOFLAGS="" go generate ./jaeger/static
    env GOFLAGS="" go generate ./multicluster/static
    env GOFLAGS="" go generate ./viz/static
  '';

  postInstall = ''
    mv $out/bin/cli $out/bin/linkerd
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd linkerd \
      --bash <($out/bin/linkerd completion bash) \
      --zsh <($out/bin/linkerd completion zsh) \
      --fish <($out/bin/linkerd completion fish)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/linkerd version --client | grep ${src.rev} > /dev/null
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/linkerd/linkerd2/pkg/version.Version=${src.rev}"
  ];

  subPackages = [ "cli" ];

  tags = [
    "prod"
  ];

  passthru.updateScript = (./. + "/update-${channel}.sh");

  meta = {
    description = "Simple Kubernetes service mesh that improves security, observability and reliability";
    homepage = "https://linkerd.io/";
    license = lib.licenses.asl20;

    maintainers = [
    ];

    mainProgram = "linkerd";
    downloadPage = "https://github.com/linkerd/linkerd2/";
  };
}
