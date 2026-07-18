{
  lib,
  fetchFromGitHub,
  buildGoModule,
  holos,
  kubectl,
  kubernetes-helm,
  kustomize,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "holos";
  version = "0.106.0";

  src = fetchFromGitHub {
    owner = "holos-run";
    repo = "holos";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IDIqSlHzmX0rdO3frDx5S+x18OJoJKMicQPx2exIMP8=";
  };

  vendorHash = "sha256-Ev8DuecVz/FVpOBk53ddF6aCRkLt7i6O4D/UU0iumHs=";

  nativeCheckInputs = [
    kubernetes-helm
    kubectl
    kustomize
  ];

  ldflags = [
    "-w"
    "-X github.com/holos-run/holos/version.GitDescribe=v${finalAttrs.version}"
    "-X github.com/holos-run/holos/version.GitCommit=${finalAttrs.src.rev}"
    "-X github.com/holos-run/holos/version.GitTreeState=clean"
    # fix time for deterministic builds
    "-X github.com/holos-run/holos/version.BuildDate=1970-01-01T00:00:00Z"
  ];

  subPackages = [ "cmd/holos" ];

  passthru.tests.version = testers.testVersion {
    version = "${finalAttrs.version}";
    command = "holos --version || true";
    package = holos;
  };

  meta = {
    description = "Holos CLI tool";
    homepage = "https://github.com/holos-run/holos";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cameronraysmith ];
    mainProgram = "holos";
  };
})
