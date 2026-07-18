{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyqt6,
  pytestCheckHook,
  qtpy,
}:

buildPythonPackage rec {
  pname = "qtawesome";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "spyder-ide";
    repo = "qtawesome";
    tag = "v${version}";
    hash = "sha256-CdELoMML7j9m1HrAY8MhKcYx5Q4xuEMZIBeyzQnRQtk=";
  };

  propagatedBuildInputs = [
    pyqt6
    qtpy
  ];

  # Requires https://github.com/boylea/qtbot which is unmaintained
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "qtawesome" ];

  meta = {
    description = "Iconic fonts in PyQt and PySide applications";
    homepage = "https://github.com/spyder-ide/qtawesome";
    changelog = "https://github.com/spyder-ide/qtawesome/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux; # fails on Darwin
    mainProgram = "qta-browser";
  };
}
