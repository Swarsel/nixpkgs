{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachetools,
  chardet,
  colorama,
  filelock,
  hatch-vcs,
  hatchling,
  packaging,
  platformdirs,
  pluggy,
  pyproject-api,
  testers,
  tox,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "tox";
  version = "4.34.1";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "tox";
    tag = version;
    hash = "sha256-pfftPTY7n47tCQFGCZRwsq0vCWZUeukFZO99gj5mTeo=";
  };

  doCheck = false; # infinite recursion via devpi-client

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    cachetools
    chardet
    colorama
    filelock
    packaging
    platformdirs
    pluggy
    pyproject-api
    virtualenv
  ];

  pyproject = true;

  passthru.tests = {
    version = testers.testVersion { package = tox; };
  };

  meta = {
    description = "Generic virtualenv management and test command line tool";
    homepage = "https://github.com/tox-dev/tox";
    changelog = "https://github.com/tox-dev/tox/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tox";
  };
}
