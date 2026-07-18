{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "kubespy";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "pulumi";
    repo = "kubespy";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-l/vOIFvCQHq+gOr38SpVZ8ShZdI1bP4G5PY4hKhkCU0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-4q+eFMrcZsEdk1W7aorIrfS3oVAuD4V0KQ7oJ/5d8nk=";
  doCheck = false;

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/kubespy completion $shell > kubespy.$shell
      installShellCompletion kubespy.$shell
    done
  '';

  ldflags = [
    "-X"
    "github.com/pulumi/kubespy/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Tool to observe Kubernetes resources in real time";
    homepage = "https://github.com/pulumi/kubespy";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "kubespy";
  };
})
