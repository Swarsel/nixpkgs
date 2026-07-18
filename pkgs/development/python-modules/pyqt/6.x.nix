{
  lib,
  stdenv,
  buildPythonPackage,
  cups,
  dbus,
  dbus-python,
  fetchPypi,
  lndir,
  mesa,
  pkg-config,
  pyqt-builder,
  pyqt6-sip,
  qt6Packages,
  sip,
  withLocation ? true,
  withMultimedia ? true,
  withPdf ? true,
  # Not currently part of PyQt6
  #, withConnectivity ? true
  withPrintSupport ? true,
  withSerialPort ? false,
  withSpeech ? true,
  withWebSockets ? true,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyqt6";
  version = "6.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Rd1gqmmXbeGRi1zta057aiWr0qkZ7O9f1YJuzHZxiIk=";
    pname = "pyqt6";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix some wrong assumptions by ./project.py
    # TODO: figure out how to send this upstream
    ./pyqt6-fix-dbus-mainloop-support.patch
    # confirm license when installing via pyqt6_sip
    ./pyqt5-confirm-license.patch
  ];

  # be more verbose
  # and normalize version
  postPatch = ''
    cat >> pyproject.toml <<EOF
    [tool.sip.project]
    verbose = true
    EOF

    substituteInPlace pyproject.toml \
      --replace-fail 'version = "${finalAttrs.version}"' 'version = "${lib.versions.pad 3 finalAttrs.version}"'
  '';

  nativeBuildInputs =
    with qt6Packages;
    [
      pkg-config
      lndir
      qtbase
      qtsvg
      qtdeclarative
      qtwebchannel
      qmake
      qtquick3d
      qtquicktimeline
    ]
    # ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withMultimedia qtmultimedia
    ++ lib.optional withWebSockets qtwebsockets
    ++ lib.optional withLocation qtlocation
    ++ lib.optional withSerialPort qtserialport
    ++ lib.optional withSpeech qtspeech
    ++ lib.optional withPdf qtwebengine;

  buildInputs =
    with qt6Packages;
    [
      dbus
      qtbase
      qtsvg
      qtdeclarative
      qtquick3d
      qtquicktimeline
    ]
    # ++ lib.optional withConnectivity qtconnectivity
    ++ lib.optional withMultimedia qtmultimedia
    ++ lib.optional withWebSockets qtwebsockets
    ++ lib.optional withLocation qtlocation
    ++ lib.optional withSerialPort qtserialport
    ++ lib.optional withSpeech qtspeech
    ++ lib.optional withPdf qtwebengine;

  propagatedBuildInputs =
    # ld: library not found for -lcups
    lib.optionals (withPrintSupport && stdenv.hostPlatform.isDarwin) [ cups ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-address-of-temporary";

  build-system = [
    sip
    pyqt-builder
  ];

  dependencies = [
    pyqt6-sip
    dbus-python
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
    export MAKEFLAGS+="''${enableParallelBuilding:+-j$NIX_BUILD_CORES}"
  '';

  pyproject = true;

  # Checked using pythonImportsCheck, has no tests
  pythonImportsCheck = [
    "PyQt6"
    "PyQt6.QtCore"
    "PyQt6.QtQml"
    "PyQt6.QtWidgets"
    "PyQt6.QtGui"
    "PyQt6.QtQuick"
  ]
  ++ lib.optional withWebSockets "PyQt6.QtWebSockets"
  ++ lib.optional withMultimedia "PyQt6.QtMultimedia"
  # ++ lib.optional withConnectivity "PyQt6.QtConnectivity"
  ++ lib.optional withLocation "PyQt6.QtPositioning"
  ++ lib.optional withSerialPort "PyQt6.QtSerialPort"
  ++ lib.optional withSpeech "PyQt6.QtTextToSpeech"
  ++ lib.optional withPdf "PyQt6.QtPdf";

  passthru = {
    inherit sip pyqt6-sip;
    WebSocketsEnabled = withWebSockets;
    multimediaEnabled = withMultimedia;
    serialPortEnabled = withSerialPort;
  };

  meta = {
    inherit (mesa.meta) platforms;
    description = "Python bindings for Qt6";
    homepage = "https://riverbankcomputing.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ LunNova ];
  };
})
