{
  lib,
  apptools,
  buildPythonPackage,
  envisage,
  fetchPypi,
  numpy,
  packaging,
  pyface,
  pygments,
  pyqt5,
  traitsui,
  vtk,
  wrapQtAppsHook,
}:

buildPythonPackage rec {
  pname = "mayavi";
  version = "4.8.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-72nMvfWPIPGzlJMNXjoW3aSxo5rcvHb3mr0mSD0prPU=";
  };

  nativeBuildInputs = [ wrapQtAppsHook ];

  propagatedBuildInputs = [
    apptools
    envisage
    numpy
    packaging
    pyface
    pygments
    pyqt5
    traitsui
    vtk
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";
  # Needs X server
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  format = "setuptools";
  pythonImportsCheck = [ "mayavi" ];
  # stripping the ico file on macos cause segfault
  stripExclude = [ "*.ico" ];

  meta = {
    description = "3D visualization of scientific data in Python";
    homepage = "https://github.com/enthought/mayavi";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
    mainProgram = "mayavi2";
  };
}
