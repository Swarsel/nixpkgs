{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  datalad,
  datalad-next,
  git,
  git-annex,
  outdated,
  pyqtdarktheme,
  pyside6,
  pytest-qt,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage {
  pname = "datalad-gooey";
  # many bug fixes on `master` but no new release
  version = "unstable-2024-02-20";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datalad-gooey";
    rev = "5bd6b9257ff1569439d2a77663271f5d665e61b6";
    hash = "sha256-8779SLcV4wwJ3124lteGzvimDxgijyxa818ZrumPMs4=";
  };

  patches = [
    # https://github.com/datalad/datalad-gooey/pull/441
    ./setuptools.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-qt
    git
    git-annex
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools ];

  dependencies = [
    pyside6
    pyqtdarktheme
    datalad-next
    outdated
    datalad
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    "test_lsfiles"
  ];

  pyproject = true;
  pythonImportsCheck = [ "datalad_gooey" ];
  pythonRemoveDeps = [ "applescript" ];

  meta = {
    description = "Graphical user interface (GUI) for DataLad";
    homepage = "https://github.com/datalad/datalad-gooey";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
    mainProgram = "datalad-gooey";
  };
}
