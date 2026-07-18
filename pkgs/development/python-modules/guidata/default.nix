{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  distutils,
  # passthru.tests
  guidata,
  h5py,
  numpy,
  pyqt5,
  pyqt6,
  pyside2,
  pyside6,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  qt5,
  qt6,
  qtpy,
  requests,
  # build-system
  setuptools,
  tomli,
}:

buildPythonPackage rec {
  pname = "guidata";
  version = "3.14.2";

  src = fetchFromGitHub {
    owner = "PlotPyStack";
    repo = "guidata";
    tag = "v${version}";
    hash = "sha256-iUfZX51Ef1PY7roy9ER8hG34BAhCLs3Sagoasd5BT3E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    # Not propagating this, to allow one to choose to choose a pyqt / pyside
    # implementation.
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
    distutils
    h5py
    numpy
    qtpy
    requests
    tomli
  ];

  # https://github.com/PlotPyStack/guidata/issues/97
  disabled = pythonAtLeast "3.14";

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fatal Python error: Segmentation fault
    # guidata/dataset/qtitemwidgets.py", line 633 in __init__
    "test_all_items"
    "test_loadsave_hdf5"
    "test_loadsave_json"
    # guidata/dataset/qtitemwidgets.py", line 581 in __init__
    "test_editgroupbox"
    "test_item_order"
    # guidata/qthelpers.py", line 710 in exec_dialog
    "test_arrayeditor"
  ];

  pyproject = true;
  pythonImportsCheck = [ "guidata" ];

  passthru = {
    # Upstream doesn't officially supports all of them, although they use qtpy,
    # see: https://github.com/PlotPyStack/PlotPy/issues/20 . See also the
    # comment near this attribute at plotpy
    knownFailingTests = {
      withPySide2 = guidata.override {
        pyqt6 = pyside2;
        qt6 = qt5;
      };
    };

    tests = {
      withPyQt5 = guidata.override {
        pyqt6 = pyqt5;
        qt6 = qt5;
      };

      withPyQt6 = guidata.override {
        pyqt6 = pyqt6;
        qt6 = qt6;
      };

      withPySide6 = guidata.override {
        pyqt6 = pyside6;
        qt6 = qt6;
      };
    };
  };

  meta = {
    description = "Python library generating graphical user interfaces for easy dataset editing and display";
    homepage = "https://github.com/PlotPyStack/guidata";

    changelog = "https://github.com/PlotPyStack/guidata/blob/master/doc/release_notes/release_${lib.versions.major version}.${
      lib.pipe version [
        lib.versions.minor
        (lib.fixedWidthString 2 "0")
      ]
    }.md";

    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
