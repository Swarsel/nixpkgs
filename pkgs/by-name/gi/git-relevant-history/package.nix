{
  lib,
  fetchFromGitHub,
  git,
  git-filter-repo,
  python3,
  unstableGitUpdater,
}:

python3.pkgs.buildPythonApplication {
  pname = "git-relevant-history";
  version = "1.0.0-unstable-2022-09-15";

  src = fetchFromGitHub {
    owner = "rainlabs-eu";
    repo = "git-relevant-history";
    rev = "84552324d7cb4790db86282fc61bf98a05b7a4fd";
    hash = "sha256-46a6TR1Hi3Lg2DTmOp1aV5Uhd4IukTojZkA3TVbTnRY=";
  };

  build-system = [ python3.pkgs.setuptools ];

  dependencies = [
    git
    git-filter-repo
    python3.pkgs.docopt
  ];

  pyproject = true;
  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = {
    description = "Extract only relevant history from git repo";
    homepage = "https://github.com/rainlabs-eu/git-relevant-history";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.bendlas ];
    platforms = lib.platforms.all;
    mainProgram = "git-relevant-history";
  };
}
