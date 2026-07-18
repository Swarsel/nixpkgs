{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "weave-gitops";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "weaveworks";
    repo = "weave-gitops";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Gm4DIQK8T+dTwB5swdrD+SjGgy/wFQ/fJYdSqNDSy9c=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-RiPBlpEQ69fhVf3B0qHQ+zEtPIet/Y/Jp/HfaTrIssE=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gitops \
      --bash <($out/bin/gitops completion bash 2>/dev/null) \
      --fish <($out/bin/gitops completion fish 2>/dev/null) \
      --zsh <($out/bin/gitops completion zsh 2>/dev/null)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/weaveworks/weave-gitops/cmd/gitops/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/gitops" ];

  meta = {
    description = "Weave Gitops CLI";
    homepage = "https://docs.gitops.weave.works";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "gitops";
  };
})
