{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  clusterctl,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "clusterctl";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "cluster-api";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ValaeZiYlSXydMwmcGMcBXETWweu3d4XRb+fHnangp4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-GeZUJozumnxXGIJ4moXxuLDATeJDRbTeGDdscZIvjh0=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # errors attempting to write config to read-only $HOME
    export HOME=$TMPDIR

    installShellCompletion --cmd clusterctl \
      --bash <($out/bin/clusterctl completion bash) \
      --fish <($out/bin/clusterctl completion fish) \
      --zsh <($out/bin/clusterctl completion zsh)
  '';

  ldflags =
    let
      t = "sigs.k8s.io/cluster-api/version";
    in
    [
      "-X ${t}.gitMajor=${lib.versions.major finalAttrs.version}"
      "-X ${t}.gitMinor=${lib.versions.minor finalAttrs.version}"
      "-X ${t}.gitVersion=v${finalAttrs.version}"
    ];

  subPackages = [ "cmd/clusterctl" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "HOME=$TMPDIR clusterctl version";
    package = clusterctl;
  };

  meta = {
    description = "Kubernetes cluster API tool";
    homepage = "https://cluster-api.sigs.k8s.io/";
    changelog = "https://github.com/kubernetes-sigs/cluster-api/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qjoly ];
    mainProgram = "clusterctl";
  };
})
