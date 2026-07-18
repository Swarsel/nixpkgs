{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pluggy,
  pyqt5,
  pytest,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-qt";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-qt";
    tag = version;
    hash = "sha256-ZCWWhd1/7qdSgGLNbsjPlxg24IFdqbNtLRktgMFVCJY=";
  };

  buildInputs = [ pytest ];
  # Tests require X server
  doCheck = false;
  nativeCheckInputs = [ pyqt5 ];
  build-system = [ setuptools-scm ];

  dependencies = [
    pluggy
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytestqt" ];

  meta = {
    description = "Pytest support for PyQt and PySide applications";
    homepage = "https://github.com/pytest-dev/pytest-qt";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
