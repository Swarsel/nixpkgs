{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  python-lzo,
  tkinter,
}:

buildPythonPackage rec {
  pname = "readmdict";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "ffreemt";
    repo = "readmdict";
    rev = "v${version}";
    hash = "sha256-1/f+o2bVscT3EA8XQyS2hWjhimLRzfIBM6u2O7UqwcA=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    python-lzo
    tkinter
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "readmdict" ];

  meta = {
    description = "Read mdx/mdd files (repacking of readmdict from mdict-analysis)";
    homepage = "https://github.com/ffreemt/readmdict";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "readmdict";
  };
}
