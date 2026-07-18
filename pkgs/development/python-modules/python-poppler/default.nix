{
  lib,
  buildPythonPackage,
  fetchPypi,
  meson-python,
  ninja,
  pkg-config,
  poppler,
  pybind11,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-poppler";
  version = "0.4.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5spcI+wCNQvyzvhaa/nxsmF5ZDbbR4F2+dJPsU7uzGo=";
    pname = "python_poppler";
  };

  patches = [
    # Prevent Meson from downloading pybind11, use system version instead
    ./use_system_pybind11.patch
    # Fix build with Poppler 25.01+
    # See: https://github.com/cbrunet/python-poppler/pull/92
    ./poppler-25.patch
  ];

  nativeBuildInputs = [
    ninja
    pkg-config
  ];

  buildInputs = [ pybind11 ];
  propagatedBuildInputs = [ poppler ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ meson-python ];
  pyproject = true;
  pythonImportsCheck = [ "poppler" ];

  meta = {
    description = "Python binding to poppler-cpp";
    homepage = "https://github.com/cbrunet/python-poppler";
    changelog = "https://cbrunet.net/python-poppler/changelog.html";
    # Contradictory license definition
    # https://github.com/cbrunet/python-poppler/issues/90
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.onny ];
  };
}
