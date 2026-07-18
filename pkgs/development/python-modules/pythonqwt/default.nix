{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  # tests
  pyqt6,
  pytestCheckHook,
  qt6,
  qtpy,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pythonqwt";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "PlotPyStack";
    repo = "PythonQwt";
    tag = "v${version}";
    hash = "sha256-uCCbKlyqeXUcmFYz/0b/+vpL7vivO8qn0L2PHgfN1H8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    # Not propagating this, to allow one to choose to either choose a pyqt /
    # pyside implementation
    pyqt6
  ];

  preCheck = ''
    export QT_PLUGIN_PATH="${lib.getBin qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM=offscreen
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    qtpy
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "qwt" ];

  meta = {
    description = "Qt plotting widgets for Python (pure Python reimplementation of Qwt C++ library)";
    homepage = "https://github.com/PlotPyStack/PythonQwt";
    changelog = "https://github.com/PlotPyStack/PythonQwt/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
