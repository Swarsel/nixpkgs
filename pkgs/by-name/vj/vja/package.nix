{
  lib,
  fetchFromGitLab,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "vja";
  version = "5.3.0";

  src = fetchFromGitLab {
    owner = "ce72";
    repo = "vja";
    tag = finalAttrs.version;
    hash = "sha256-SLvr5e55XY+Yl3n5H6vvBV0nQ2DRcdIFaM8Wp0BGRrs=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    click
    click-aliases
    parsedatetime
    pyjwt
    python-dateutil
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "vja"
  ];

  meta = {
    description = "Command line interface for Vikunja";
    homepage = "https://gitlab.com/ce72/vja";
    changelog = "https://gitlab.com/ce72/vja/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ iv-nn ];
    mainProgram = "vja";
  };
})
