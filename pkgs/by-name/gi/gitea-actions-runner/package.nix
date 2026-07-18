{
  lib,
  buildGoModule,
  fetchFromGitea,
  gitea-actions-runner,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gitea-actions-runner";
  version = "1.0.3";

  src = fetchFromGitea {
    owner = "gitea";
    repo = "runner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-p6NdkQiZiEeuQjJp3CKTayStZlyk3d1XGigSI5uuLp0=";
    domain = "gitea.com";
  };

  vendorHash = "sha256-T1T5ZpGqGmipIkTWlYxlsLdAthW8bhcAvr0xyZ74+wQ=";
  # Tests require network access (artifactcache tests try to determine outbound IP)
  doCheck = false;

  postInstall = ''
    mv "$out/bin/runner" "$out/bin/gitea-runner"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X gitea.com/gitea/runner/internal/pkg/ver.version=v${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = gitea-actions-runner;
  };

  meta = {
    description = "Runner for Gitea based on act";
    homepage = "https://gitea.com/gitea/runner";
    changelog = "https://gitea.com/gitea/runner/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ techknowlogick ];
    mainProgram = "gitea-runner";
  };
})
