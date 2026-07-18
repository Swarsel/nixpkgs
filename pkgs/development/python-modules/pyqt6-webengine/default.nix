{
  lib,
  buildPythonPackage,
  fetchPypi,
  lndir,
  mesa,
  pkg-config,
  pyqt-builder,
  pyqt6,
  python,
  qt6Packages,
  sip,
}:

buildPythonPackage rec {
  pname = "pyqt6-webengine";
  version = "6.11.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Fc9J77u9TGvIdlOyxK6A1gSfgA4xYgszZzSuLjfL7a4=";
    pname = "pyqt6_webengine";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./qvariant.patch
  ];

  # fix include path and increase verbosity
  postPatch = ''
    sed -i \
      '/\[tool.sip.project\]/a\
      verbose = true\
      sip-include-dirs = [\"${pyqt6}/${python.sitePackages}/PyQt6/bindings\"]' \
      pyproject.toml
  '';

  nativeBuildInputs = with qt6Packages; [
    pkg-config
    lndir
    qtwebengine
    qmake
  ];

  buildInputs = with qt6Packages; [ qtwebengine ];

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

  # HACK: paralellize compilation of make calls within pyqt's setup.py
  # pkgs/stdenv/generic/setup.sh doesn't set this for us because
  # make gets called by python code and not its build phase
  # format=pyproject means the pip-build-hook hook gets used to build this project
  # pkgs/development/interpreters/python/hooks/pip-build-hook.sh
  # does not use the enableParallelBuilding flag
  postUnpack = ''
    export MAKEFLAGS+=" -j$NIX_BUILD_CORES"
  '';

  pyproject = true;

  # Checked using pythonImportsCheck, has no tests
  pythonImportsCheck = [
    "PyQt6.QtWebEngineCore"
    "PyQt6.QtWebEngineQuick"
    "PyQt6.QtWebEngineWidgets"
  ];

  passthru = {
    inherit sip;
  };

  meta = {
    inherit (mesa.meta) platforms;
    description = "Python bindings for Qt6 WebEngine";
    homepage = "https://riverbankcomputing.com/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      LunNova
    ];
  };
}
