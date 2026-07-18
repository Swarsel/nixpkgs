{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "podman-compose";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "podman-compose";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zkXLZfYWpIaQYoUU7GcGnkuTBmhzpJkyojbzFuTR5FI=";
  };

  propagatedBuildInputs = [ python3Packages.pypaBuildHook ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    parameterized
  ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    python-dotenv
    pyyaml
  ];

  disabledTestPaths = [
    "tests/integration" # requires running podman
  ];

  pyproject = true;

  # versionCheckHook requires podman executable
  meta = {
    description = "Implementation of docker-compose with podman backend";
    homepage = "https://github.com/containers/podman-compose";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "podman-compose";
    teams = [ lib.teams.podman ];
  };
})
