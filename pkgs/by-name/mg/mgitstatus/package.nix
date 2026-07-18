{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mgitstatus";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "fboender";
    repo = "multi-git-status";
    rev = finalAttrs.version;
    hash = "sha256-DToyP6TD9up0k2/skMW3el6hNvKD+c8q2zWpk0QZGRA=";
  };

  installFlags = [
    "PREFIX=$(out)"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Show uncommitted, untracked and unpushed changes for multiple Git repos";
    homepage = "https://github.com/fboender/multi-git-status";
    changelog = "https://github.com/fboender/multi-git-status/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getpsyched ];
    platforms = lib.platforms.all;
    mainProgram = "mgitstatus";
    downloadPage = "https://github.com/fboender/multi-git-status/releases/tag/v${finalAttrs.version}";
  };
})
