{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubernetes-kcp,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubernetes-kcp";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "kcp-dev";
    repo = "kcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rZLav2JOKzG5vW/wyfk7EIkOawsYOmG32OHXxkyyb3Y=";
  };

  # TODO: Check if this is necessary.
  # __darwinAllowLocalNetworking = true;
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-IuQzGme+CZqqD1VMO+rumbbc+ziPQaVJCyJNhMdU3jE=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/kcp completion bash > kcp.bash
    $out/bin/kcp completion zsh > kcp.zsh
    $out/bin/kcp completion fish > kcp.fish
    installShellCompletion kcp.{bash,zsh,fish}
  '';

  # TODO: The upstream has the additional version information pulled from go.mod
  # dependencies.
  ldflags = [
    "-X k8s.io/client-go/pkg/version.gitCommit=unknown"
    "-X k8s.io/client-go/pkg/version.gitTreeState=clean"
    "-X k8s.io/client-go/pkg/version.gitVersion=v${finalAttrs.version}"
    # "-X k8s.io/client-go/pkg/version.gitMajor=${KUBE_MAJOR_VERSION}"
    # "-X k8s.io/client-go/pkg/version.gitMinor=${KUBE_MINOR_VERSION}"
    "-X k8s.io/client-go/pkg/version.buildDate=unknown"
    "-X k8s.io/component-base/version.gitCommit=unknown"
    "-X k8s.io/component-base/version.gitTreeState=clean"
    "-X k8s.io/component-base/version.gitVersion=v${finalAttrs.version}"
    # "-X k8s.io/component-base/version.gitMajor=${KUBE_MAJOR_VERSION}"
    # "-X k8s.io/component-base/version.gitMinor=${KUBE_MINOR_VERSION}"
    "-X k8s.io/component-base/version.buildDate=unknown"
  ];

  subPackages = [ "cmd/kcp" ];

  passthru.tests.version = testers.testVersion {
    # NOTE: Once the go.mod version is pulled in, the version info here needs
    # to be also updated.
    version = "v${finalAttrs.version}";
    command = "kcp --version";
    package = kubernetes-kcp;
  };

  meta = {
    description = "Kubernetes-like control planes for form-factors and use-cases beyond Kubernetes and container workloads";
    homepage = "https://kcp.io";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      rytswd
    ];

    mainProgram = "kcp";
  };
})
