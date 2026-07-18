{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "termgraph";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "mkaz";
    repo = "termgraph";
    tag = "v${version}";
    hash = "sha256-ruztSbouRpi88fMB6kijbHFZzS3ZvwqP/BBmTE3DlDs=";
  };

  propagatedBuildInputs = [ colorama ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "termgraph" ];

  meta = {
    description = "Python command-line tool which draws basic graphs in the terminal";
    homepage = "https://github.com/mkaz/termgraph";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
    mainProgram = "termgraph";
  };
}
