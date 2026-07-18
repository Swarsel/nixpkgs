{
  lib,
  fetchFromGitHub,
  python3,
  smassh,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "smassh";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "kraanzu";
    repo = "smassh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4w7mkZrm8m3MA18QLRRoRF022aaQP64iUGKUWsskqDk=";
  };

  nativeBuildInputs = with python3.pkgs; [ hatchling ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    platformdirs
    requests
    textual
  ];

  # No tests available
  doCheck = false;
  pyproject = true;

  pythonRelaxDeps = [
    "platformdirs"
    "textual"
  ];

  passthru.tests.version = testers.testVersion {
    version = "smassh - v${finalAttrs.version}";
    command = "HOME=$(mktemp -d) smassh --version";
    package = smassh;
  };

  meta = {
    description = "TUI based typing test application inspired by MonkeyType";
    homepage = "https://github.com/kraanzu/smassh";
    changelog = "https://github.com/kraanzu/smassh/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aimpizza
      kraanzu
    ];

    mainProgram = "smassh";
  };
})
