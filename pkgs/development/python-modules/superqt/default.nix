{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pint,
  pygments,
  pyqt5,
  pyqt6,
  pyside2,
  pyside6,
  pytestCheckHook,
  qtpy,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "superqt";
  version = "0.7.8";

  src = fetchFromGitHub {
    owner = "pyapp-kit";
    repo = "superqt";
    tag = "v${version}";
    hash = "sha256-ipDtwymKocCRwcW/eYpM6jrmrjkYQJlaEyaSV4SinMM=";
  };

  # Segmentation fault
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    pygments
    qtpy
    typing-extensions
  ];

  optional-dependencies = {
    pyqt5 = [ pyqt5 ];
    pyqt6 = [ pyqt6 ];
    pyside2 = [ pyside2 ];
    pyside6 = [ pyside6 ];
    quantity = [ pint ];
  };

  pyproject = true;

  # Segmentation fault
  # pythonImportsCheck = [ "superqt" ];
  meta = {
    description = "Missing widgets and components for Qt-python (napari/superqt)";
    homepage = "https://github.com/napari/superqt";
    changelog = "https://github.com/pyapp-kit/superqt/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
}
