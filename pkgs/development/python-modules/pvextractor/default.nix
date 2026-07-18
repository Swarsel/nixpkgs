{
  lib,
  fetchFromGitHub,
  astropy,
  buildPythonPackage,
  matplotlib,
  pyqt-builder,
  pyqt6,
  pytest-astropy,
  pytestCheckHook,
  qtpy,
  scipy,
  setuptools,
  setuptools-scm,
  spectral-cube,
}:

buildPythonPackage rec {
  pname = "pvextractor";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "radio-astro-tools";
    repo = "pvextractor";
    tag = "v${version}";
    sha256 = "sha256-TjwoTtoGWU6C6HdFuS+gJj69PUnfchPHs7UjFqwftVQ=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ pyqt-builder ];

  propagatedBuildInputs = [
    astropy
    scipy
    matplotlib
    pyqt6
    qtpy
    spectral-cube
  ];

  # collecting ... qt.qpa.xcb: could not connect to display
  # qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-astropy
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pvextractor" ];

  meta = {
    description = "Position-velocity diagram extractor";
    homepage = "http://pvextractor.readthedocs.io";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ifurther ];
  };
}
