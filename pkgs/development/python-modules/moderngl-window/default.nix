{
  lib,
  fetchFromGitHub,
  av,
  buildPythonPackage,
  glfw,
  mesa,
  # dependencies
  moderngl,
  numpy,
  pillow,
  pygame,
  pyglet,
  pyglm,
  pyqt5,
  pysdl2,
  pyside2,
  reportlab,
  scipy,
  # build-system
  setuptools,
  # optional-dependencies
  trimesh,
}:

buildPythonPackage rec {
  pname = "moderngl-window";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "moderngl";
    repo = "moderngl_window";
    tag = version;
    hash = "sha256-pElSwzNbZlZT8imK1UsLy2TyvS8TEM7hsVqLxEK1tbg=";
  };

  # Tests need a display to run.
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    moderngl
    numpy
    pillow
    pyglet
    pyglm
  ];

  optional-dependencies = {
    PySDL2 = [ pysdl2 ];
    PySide2 = [ pyside2 ];
    av = [ av ];
    glfw = [ glfw ];
    pdf = [ reportlab ];
    pygame = [ pygame ];
    pyqt5 = [ pyqt5 ];

    trimesh = [
      trimesh
      scipy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "moderngl_window" ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "Cross platform helper library for ModernGL making window creation and resource loading simple";
    homepage = "https://github.com/moderngl/moderngl-window";
    changelog = "https://github.com/moderngl/moderngl-window/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ c0deaddict ];
  };
}
