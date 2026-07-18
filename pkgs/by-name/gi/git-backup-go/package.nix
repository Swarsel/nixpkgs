{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git-backup-go,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "git-backup-go";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "ChappIO";
    repo = "git-backup";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xpHrBGgPH2dnbDz49OBntdHbowMhoz3P7k8UlNN7ku8=";
  };

  vendorHash = "sha256-xP2bV3vD4CbMGVT+MK4wJgMbIBZLvyqiMOfgj8Rc38Y=";
  ldflags = [ "-X main.Version=${finalAttrs.version}" ];

  passthru.tests.version = testers.testVersion {
    command = "git-backup -version";
    package = git-backup-go;
  };

  meta = {
    description = "Backup all your GitHub & GitLab repositories";
    homepage = "https://github.com/ChappIO/git-backup";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aleksana ];
    mainProgram = "git-backup";
  };
})
