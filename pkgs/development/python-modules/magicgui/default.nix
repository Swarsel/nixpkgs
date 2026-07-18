{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docstring-parser,
  hatch-vcs,
  hatchling,
  napari, # a reverse-dependency, for tests
  psygnal,
  pyqt5,
  pyqt6,
  pyside2,
  pyside6,
  pytestCheckHook,
  superqt,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "magicgui";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "pyapp-kit";
    repo = "magicgui";
    tag = "v${version}";
    hash = "sha256-5etnug947C+Ewk1QLxsxEeaSa9djIlM/PGdNnJZiND8=";
  };

  doCheck = false; # Reports "Fatal Python error"
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    typing-extensions
    superqt
    psygnal
    docstring-parser
  ];

  optional-dependencies = {
    pyqt5 = [ pyqt5 ];
    pyqt6 = [ pyqt6 ];
    pyside2 = [ pyside2 ];
    pyside6 = [ pyside6 ];
  };

  pyproject = true;

  passthru.tests = {
    inherit napari;
  };

  meta = {
    description = "Build GUIs from python functions, using magic.  (napari/magicgui)";
    homepage = "https://github.com/pyapp-kit/magicgui";
    changelog = "https://github.com/pyapp-kit/magicgui/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
}
