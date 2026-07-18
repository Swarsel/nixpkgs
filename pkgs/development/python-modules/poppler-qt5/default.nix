{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pkg-config,
  poppler,
  pyqt-builder,
  pyqt5,
  qmake,
  qtbase,
  setuptools,
  sip,
}:

buildPythonPackage rec {
  pname = "python-poppler-qt5";
  version = "21.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tHfohB8OoOCf2rby8wXPON+XfZ4ULlaTo3RgXXXdb+A=";
  };

  postPatch = ''
    cat <<EOF >> pyproject.toml
    [tool.sip.bindings.Poppler-Qt5]
    include-dirs = ["${poppler.dev}/include/poppler"]
    EOF
  '';

  nativeBuildInputs = [
    pkg-config
    qmake
    sip
    setuptools
  ];

  buildInputs = [
    qtbase.dev
    poppler
    pyqt-builder
  ];

  propagatedBuildInputs = [ pyqt5.dev ];
  # no tests, just bindings for `poppler_qt5`
  doCheck = false;
  disabled = !isPy3k;
  dontConfigure = true;
  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "popplerqt5" ];

  meta = {
    homepage = "https://github.com/frescobaldi/python-poppler-qt5";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
