{
  lib,
  buildPythonPackage,
  fetchPypi,
  mesa,
  pyqt-builder,
  pyqt6,
  python,
  qt6Packages,
  sip,
}:

buildPythonPackage rec {
  pname = "pyqt6-charts";
  version = "6.11.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-EJHNkZgGo84F0idnKfeb5Oy9CpOVAKiJkCbD71dpxlA=";
    pname = "pyqt6_charts";
  };

  # fix include path and increase verbosity
  postPatch = ''
    sed -i \
      '/\[tool.sip.project\]/a\
      verbose = true\
      sip-include-dirs = [\"${pyqt6}/${python.sitePackages}/PyQt6/bindings\"]' \
      pyproject.toml
  '';

  nativeBuildInputs = with qt6Packages; [
    qtcharts
    qmake
  ];

  buildInputs = with qt6Packages; [ qtcharts ];

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

  build-system = [
    sip
    pyqt-builder
  ];

  dependencies = [
    pyqt6
  ];

  dontConfigure = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;
  pyproject = true;
  pythonImportsCheck = [ "PyQt6.QtCharts" ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "Python bindings for Qt6 QtCharts";
    homepage = "https://riverbankcomputing.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
