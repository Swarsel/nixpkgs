{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  mesa,
  numpy,
  pyqt6,
  pytest-cov-stub,
  pytestCheckHook,
  qt6,
  qtpy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "echo";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "glue-viz";
    repo = "echo";
    tag = "v${version}";
    sha256 = "sha256-36uT2FpOzwuNMM4GhlTuYCSo8j7waIQgWOCN6maKaiY=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  doCheck = lib.meta.availableOn stdenv.hostPlatform mesa.llvmpipeHook;

  nativeCheckInputs = [
    mesa.llvmpipeHook
    pytestCheckHook
    pytest-cov-stub
  ];

  preCheck = ''
    export QT_QPA_PLATFORM=offscreen
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    qt6.qtconnectivity
    qt6.qtbase
    qt6.qttools
    pyqt6
    numpy
    qtpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "echo" ];

  meta = {
    description = "Callback Properties in Python";
    homepage = "https://github.com/glue-viz/echo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ifurther ];
  };
}
