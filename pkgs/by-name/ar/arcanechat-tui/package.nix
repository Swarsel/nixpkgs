{
  lib,
  fetchFromGitHub,
  arcanechat-tui,
  python3,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "arcanechat-tui";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "ArcaneChat";
    repo = "arcanechat-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-seoXvlDG2xxdM9mAKe4Yo4juDslgrniv1LOTdXbplp0=";
  };

  doCheck = false; # no tests implemented

  build-system = with python3.pythonOnBuildForHost.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    appdirs
    deltachat2
    urwid
    urwid-readline
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  passthru.tests = {
    version = testers.testVersion rec {
      command = ''
        HOME="$TEMP" ${lib.getExe package} --version
      '';

      package = arcanechat-tui;
    };
  };

  meta = {
    description = "Lightweight Delta Chat client";
    homepage = "https://github.com/ArcaneChat/arcanechat-tui";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "arcanechat-tui";
  };
})
