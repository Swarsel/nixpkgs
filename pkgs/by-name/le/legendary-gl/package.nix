{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "legendary-gl"; # Name in pypi
  version = "0.20.34";

  src = fetchFromGitHub {
    owner = "legendary-gl";
    repo = "legendary";
    rev = "56d439ed2d3d9f34e2b08fa23e627c23a487b8d6";
    hash = "sha256-yCHeeEGw+9gtRMGyIhbStxJhmSM/1Fqly7HSRDkZILQ=";
  };

  # no tests
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
    filelock
  ];

  pyproject = true;
  pythonImportsCheck = [ "legendary" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Free and open-source Epic Games Launcher alternative";
    homepage = "https://github.com/legendary-gl/legendary";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ equirosa ];
    mainProgram = "legendary";
  };
}
