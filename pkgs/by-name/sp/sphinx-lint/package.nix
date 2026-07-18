{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "sphinx-lint";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "sphinx-lint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cg/14asXB1ivKSoGuLghne7kmQiXuimYTUqmdVqba6M=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest-cov
  ];

  build-system = [
    python3.pkgs.hatch-vcs
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    polib
    regex
  ];

  pyproject = true;

  meta = {
    description = "Check for stylistic and formal issues in .rst and .py files included in the documentation";
    homepage = "https://github.com/sphinx-contrib/sphinx-lint";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "sphinx-lint";
  };
})
