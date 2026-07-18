{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  gnumake,
  go,
  installShellFiles,
  makeWrapper,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubebuilder";
  version = "4.15.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kubebuilder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iTC5HY4E54YG+isSgW2515Kz83+khzANAml78z8EG88=";
  };

  postPatch = ''
    substituteInPlace internal/cli/version/version.go \
      --replace-fail "return main.Version" 'return "v${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    makeWrapper
    git
    installShellFiles
  ];

  vendorHash = "sha256-7rXunagWkUWGL5v+xkmyLELwrIEuRVGPk4SK8/lotio=";

  postInstall = ''
    wrapProgram $out/bin/kubebuilder \
      --prefix PATH : ${
        lib.makeBinPath [
          go
          gnumake
          git
        ]
      }

    installShellCompletion --cmd kubebuilder \
      --bash <($out/bin/kubebuilder completion bash) \
      --fish <($out/bin/kubebuilder completion fish) \
      --zsh <($out/bin/kubebuilder completion zsh)
  '';

  allowGoReference = true;

  subPackages = [
    "internal/cli/cmd"
    "."
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "${finalAttrs.finalPackage}/bin/kubebuilder version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "SDK for building Kubernetes APIs using CRDs";
    homepage = "https://github.com/kubernetes-sigs/kubebuilder";
    changelog = "https://github.com/kubernetes-sigs/kubebuilder/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      hythera
    ];

    mainProgram = "kubebuilder";
  };
})
