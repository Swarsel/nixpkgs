{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "world-wall-clock";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "ddelabru";
    repo = "world-wall-clock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gwJvoXSq8H+sMTyBEA1N+KxnkGxyt5Ev+V3awCBiILg=";
  };

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    tzdata
    urwid
    xdg-base-dirs
  ];

  disabledTests = [
    # requires real tty
    "test_run_app"
  ];

  enabledTestPaths = [ "tests/*" ];
  pyproject = true;

  pythonRelaxDeps = [
    "urwid"
  ];

  meta = {
    description = "TUI application that provides a multi-timezone graphical clock in a terminal environment";
    homepage = "https://github.com/ddelabru/world-wall-clock";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ddelabru ];
    platforms = lib.platforms.all;
    mainProgram = "wwclock";
  };
})
