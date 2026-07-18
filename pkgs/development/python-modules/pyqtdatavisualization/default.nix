{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyqt-builder,
  pyqt5,
  python,
  qtdatavis3d,
  setuptools,
  sip,
}:

buildPythonPackage rec {
  pname = "pyqtdatavisualization";
  version = "5.15.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ntM7IOdHvGnh1hnxR7sWJcwA1u9ATb8Ha6E6n/b2Bh0=";
    pname = "PyQtDataVisualization";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "[tool.sip.project]" "[tool.sip.project]''\nsip-include-dirs = [\"${pyqt5}/${python.sitePackages}/PyQt5/bindings\"]"
  '';

  nativeBuildInputs = [
    sip
    qtdatavis3d
    setuptools
    pyqt-builder
  ];

  buildInputs = [ qtdatavis3d ];
  propagatedBuildInputs = [ pyqt5 ];

  # HACK: paralellize compilation of make calls within pyqt's setup.py
  # pkgs/stdenv/generic/setup.sh doesn't set this for us because
  # make gets called by python code and not its build phase
  # format=pyproject means the pip-build-hook hook gets used to build this project
  # pkgs/development/interpreters/python/hooks/pip-build-hook.sh
  # does not use the enableParallelBuilding flag
  preBuild = ''
    export MAKEFLAGS+="''${enableParallelBuilding:+-j$NIX_BUILD_CORES}"
  '';

  # has no tests
  doCheck = false;
  dontConfigure = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;
  pyproject = true;
  pythonImportsCheck = [ "PyQt5.QtDataVisualization" ];

  meta = {
    description = "Python bindings for the Qt Data Visualization library";
    homepage = "https://riverbankcomputing.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ panicgh ];
  };
}
