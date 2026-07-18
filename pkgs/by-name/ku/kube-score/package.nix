{
  lib,
  fetchFromGitHub,
  buildGoModule,
  kube-score,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kube-score";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "zegl";
    repo = "kube-score";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZqhuqPWCfJKi38Jdazr5t5Wulsqzl1D4/81ZTvW10Co=";
  };

  vendorHash = "sha256-uv+82x94fEa/3tjcofLGIPhJpwUzSkEbarGVq8wVEUc=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "kube-score version";
      package = kube-score;
    };
  };

  meta = {
    description = "Kubernetes object analysis with recommendations for improved reliability and security";
    homepage = "https://github.com/zegl/kube-score";
    changelog = "https://github.com/zegl/kube-score/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ j4m3s ];
    mainProgram = "kube-score";
  };
})
