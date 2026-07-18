{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubeshark,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubeshark";
  version = "53.3.0";

  src = fetchFromGitHub {
    owner = "kubeshark";
    repo = "kubeshark";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YKR0P/4X134NTPuXeh1Ha781wav7daAxp+xJWCmgkIw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-4s1gxJo2w5BibZ9CJP7Jl9Z8Zzo8WpBokBnRN+zp8b4=";
  doCheck = true;

  checkPhase = ''
    go test ./...
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kubeshark \
      --bash <($out/bin/kubeshark completion bash) \
      --fish <($out/bin/kubeshark completion fish) \
      --zsh <($out/bin/kubeshark completion zsh)
  '';

  # Tests bind loopback sockets via httptest.
  __darwinAllowLocalNetworking = true;

  ldflags =
    let
      t = "github.com/kubeshark/kubeshark";
    in
    [
      "-s"
      "-w"
      "-X ${t}/misc.GitCommitHash=${finalAttrs.src.tag}"
      "-X ${t}/misc.Branch=master"
      "-X ${t}/misc.BuildTimestamp=0"
      "-X ${t}/misc.Platform=unknown"
      "-X ${t}/misc.Ver=${finalAttrs.version}"
    ];

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "kubeshark version";
      package = kubeshark;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "API Traffic Viewer for Kubernetes";

    longDescription = ''
      The API traffic viewer for Kubernetes providing real-time, protocol-aware visibility into Kubernetes’ internal network,
      Think TCPDump and Wireshark re-invented for Kubernetes
      capturing, dissecting and monitoring all traffic and payloads going in, out and across containers, pods, nodes and clusters.
    '';

    homepage = "https://kubeshark.com/";
    changelog = "https://github.com/kubeshark/kubeshark/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      qjoly
      miniharinn
    ];

    mainProgram = "kubeshark";
  };
})
