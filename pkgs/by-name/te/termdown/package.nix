{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "termdown";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "trehn";
    repo = "termdown";
    tag = finalAttrs.version;
    hash = "sha256-G2YOAC+b++oQUicZcY28qVDy2XqW2SuzhXcVqeSQkh8=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    art
    pillow
    python-dateutil
  ];

  pyproject = true;

  meta = {
    description = "Starts a countdown to or from TIMESPEC";
    longDescription = "Countdown timer and stopwatch in your terminal";
    homepage = "https://github.com/trehn/termdown";
    changelog = "https://github.com/trehn/termdown/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3;
    mainProgram = "termdown";
  };
})
