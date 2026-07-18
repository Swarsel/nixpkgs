{
  lib,
  fetchFromGitHub,
  buildGoModule,
  kubedog,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubedog";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "werf";
    repo = "kubedog";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xBTz1Ux2W0A0leOPNu0yONiz55LiYcYiviKEi8xsUTU=";
  };

  vendorHash = "sha256-kCS7nMFskBw6LTV5EgPSufxo78OyfW9Zdqe5rZytgKE=";
  # There are no tests.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/werf/kubedog.Version=${finalAttrs.src.rev}"
  ];

  subPackages = [ "cmd/kubedog" ];

  passthru.tests.version = testers.testVersion {
    version = finalAttrs.src.rev;
    command = "kubedog version";
    package = kubedog;
  };

  meta = {
    description = ''
      A tool to watch and follow Kubernetes resources in CI/CD deployment
      pipelines
    '';

    homepage = "https://github.com/werf/kubedog";
    changelog = "https://github.com/werf/kubedog/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azahi ];
    mainProgram = "kubedog";
  };
})
