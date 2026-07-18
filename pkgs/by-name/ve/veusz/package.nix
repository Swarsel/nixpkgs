{
  lib,
  fetchPypi,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "veusz";
  version = "4.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+txG1MQWbZaVq322p4ZctzanPw+geEf9ilu5kGQI3Qk=";
  };

  # vectorfield.vsz renders a PPM bitmap whose pixel values differ across Qt versions/platforms
  patches = [ ./skip-vectorfield-test.patch ];

  # pyqt_setuptools.py uses the platlib path from sysconfig, but NixOS doesn't
  # really have a corresponding path, so patching the location of PyQt5 inplace
  postPatch = ''
    substituteInPlace pyqt_setuptools.py \
      --replace-fail "get_path('platlib')" "'${python3Packages.pyqt5}/${python3Packages.python.sitePackages}'"
    patchShebangs tests/runselftest.py
  '';

  nativeBuildInputs = [
    python3Packages.sip
    python3Packages.tomli
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ qt6.qtbase ];

  installCheckPhase = ''
    runHook preInstallCheck

    wrapQtApp "tests/runselftest.py"
    QT_QPA_PLATFORM=minimal tests/runselftest.py

    runHook postInstallCheck
  '';

  preFixup = ''
    wrapQtApp "$out/bin/veusz"
  '';

  dependencies = with python3Packages; [
    numpy
    pyqt6
    # optional requirements:
    dbus-python
    h5py
    # astropy -- fails to build on master
    # optional TODO: add iminuit, pyemf and sampy
  ];

  dontUseQmakeConfigure = true;
  # veusz is a script and not an ELF-executable, so wrapQtAppsHook will not wrap
  # it automatically -> we have to do it explicitly
  dontWrapQtApps = true;
  format = "setuptools";

  # you can find these options at
  # https://github.com/veusz/veusz/blob/53b99dffa999f2bc41fdc5335d7797ae857c761f/pyqtdistutils.py#L71
  setupPyBuildFlags = [
    # veusz tries to find a libinfix and fails without one
    # but we simply don't need a libinfix, so set it to empty here
    "--qt-libinfix="
  ];

  meta = {
    description = "Scientific plotting and graphing program with a GUI";
    homepage = "https://veusz.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ laikq ];
    platforms = lib.platforms.linux;
    mainProgram = "veusz";
  };
})
