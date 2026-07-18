{
  lib,
  stdenv,
  cmake,
  distutils,
  pyside2,
  python,
  qt5,
  shiboken2,
  wrapPython,
}:

stdenv.mkDerivation {
  inherit (pyside2) version src;
  pname = "pyside2-tools";

  patches = [
    # Upstream has a crazy build system only geared towards producing binary
    # wheels distributed via pypi.  For this, they copy the `uic` and `rcc`
    # binaries to the wheel.
    ./remove_hacky_binary_copying.patch
  ];

  postPatch = ''
    cd sources/pyside2-tools
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.1)" \
      "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    distutils
    wrapPython
  ];

  buildInputs = [
    python
    qt5.qtbase
  ];

  propagatedBuildInputs = [
    shiboken2
    pyside2
  ];

  cmakeFlags = [ "-DBUILD_TESTS=OFF" ];

  # The upstream build system consists of a `setup.py` whichs builds three
  # different python libraries and calls cmake as a subprocess.  We call cmake
  # directly because that's easier to get working.  However, the `setup.py`
  # build also creates a few wrapper scripts, which we replicate here:
  postInstall = ''
    rm $out/bin/pyside_tool.py

    for tool in uic rcc; do
      makeWrapper "$(command -v $tool)" $out/bin/pyside2-$tool --add-flags "-g python"
    done
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  dontWrapQtApps = true;

  meta = {
    description = "PySide2 development tools";
    homepage = "https://wiki.qt.io/Qt_for_Python";
    license = lib.licenses.gpl2;
    maintainers = [ ];
  };
}
