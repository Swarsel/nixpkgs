{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "typstwriter";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "Bzero";
    repo = "typstwriter";
    tag = "V${finalAttrs.version}";
    hash = "sha256-0tCl/dMSWmUWZEVystb6BIYTwW7b6PH4LyERK4mi/LQ=";
  };

  build-system = [ python3.pkgs.flit-core ];

  dependencies = with python3.pkgs; [
    platformdirs
    pygments
    pyside6
    qtpy
    superqt
  ];

  optional-dependencies = with python3.pkgs; {
    tests = [
      pytest
      pytest-qt
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "typstwriter" ];

  meta = {
    description = "Integrated editor for the typst typesetting system";
    homepage = "https://github.com/Bzero/typstwriter";
    changelog = "https://github.com/Bzero/typstwriter/releases/tag/V${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "typstwriter";
  };
})
