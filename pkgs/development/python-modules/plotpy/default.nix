{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  guidata,
  numpy,
  pillow,
  # passthru.tests
  plotpy,
  pyqt5,
  pyqt6,
  pyside2,
  pyside6,
  # tests
  pytestCheckHook,
  pythonqwt,
  qt5,
  qt6,
  scikit-image,
  scipy,
  setuptools,
  tifffile,
}:

buildPythonPackage rec {
  pname = "plotpy";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "PlotPyStack";
    repo = "PlotPy";
    tag = "v${version}";
    hash = "sha256-6nLkpzwQEvaX9dlrpK6IKaDSOX6hAks9p4FjpXFTJjI=";
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
    # https://github.com/NixOS/nixpkgs/issues/255262
    cd $out
  '';

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    guidata
    numpy
    pillow
    pythonqwt
    scikit-image
    scipy
    tifffile
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fatal Python error: Segmentation fault
    # in plotpy/widgets/resizedialog.py", line 99 in __init__
    "test_resize_dialog"
    "test_tool"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "plotpy"
    "plotpy.tests"
  ];

  passthru = {
    # Upstream doesn't officially supports all of them, although they use
    # qtpy, see: https://github.com/PlotPyStack/PlotPy/issues/20
    knownFailingTests = {
      # Was failing with a peculiar segmentation fault during the tests, since
      # this package was added to Nixpkgs. This is not too bad as PySide2
      # shouldn't be used for modern applications.
      withPySide2 = plotpy.override {
        pyqt6 = pyside2;
        qt6 = qt5;
      };

      # Has started failing too similarly to pyside2, ever since a certain
      # version bump. See also:
      # https://github.com/PlotPyStack/PlotPy/blob/v2.7.4/README.md?plain=1#L62
      withPySide6 = plotpy.override {
        pyqt6 = pyside6;
        qt6 = qt6;
      };
    };

    tests = {
      withPyQt5 = plotpy.override {
        pyqt6 = pyqt5;
        qt6 = qt5;
      };

      withPyQt6 = plotpy.override {
        pyqt6 = pyqt6;
        qt6 = qt6;
      };
    };
  };

  meta = {
    description = "Curve and image plotting tools for Python/Qt applications";
    homepage = "https://github.com/PlotPyStack/PlotPy";

    changelog = "https://github.com/PlotPyStack/PlotPy/blob/master/doc/release_notes/release_${lib.versions.major version}.${
      lib.pipe version [
        lib.versions.minor
        (lib.fixedWidthString 2 "0")
      ]
    }.md";

    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
