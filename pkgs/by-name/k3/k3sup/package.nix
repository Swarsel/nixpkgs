{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  openssh,
}:

buildGoModule (finalAttrs: {
  pname = "k3sup";
  version = "0.13.12";

  src = fetchFromGitHub {
    owner = "alexellis";
    repo = "k3sup";
    rev = finalAttrs.version;
    sha256 = "sha256-+YJacemEnUBEUZBKYgr/lBzt6Y8+U1rqgs/3vDxpLfs=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = null;
  env.CGO_ENABLED = 0;

  postConfigure = ''
    substituteInPlace vendor/github.com/alexellis/go-execute/v2/exec.go \
      --replace "/bin/bash" "${bash}/bin/bash"
  '';

  postInstall = ''
    wrapProgram "$out/bin/k3sup" \
      --prefix PATH : ${lib.makeBinPath [ openssh ]}

    installShellCompletion --cmd k3sup \
      --bash <($out/bin/k3sup completion bash) \
      --zsh <($out/bin/k3sup completion zsh) \
      --fish <($out/bin/k3sup completion fish)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/alexellis/k3sup/cmd.GitCommit=ref/tags/${finalAttrs.version}"
    "-X github.com/alexellis/k3sup/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Bootstrap Kubernetes with k3s over SSH";
    homepage = "https://github.com/alexellis/k3sup";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      welteki
      qjoly
    ];

    mainProgram = "k3sup";
  };
})
