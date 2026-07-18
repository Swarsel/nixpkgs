{
  lib,
  stdenv,
  fetchFromGitHub,
  appdirs,
  babel,
  buildPythonPackage,
  evdev,
  mock,
  plover-stroke,
  pyqt5,
  pyserial,
  pytest-qt,
  pytestCheckHook,
  python-xlib,
  rtf-tokenize,
  setuptools,
  versionCheckHook,
  wcwidth,
  wheel,
  wrapQtAppsHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "plover";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "openstenoproject";
    repo = "plover";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VpQT25bl8yPG4J9IwLkhSkBt31Y8BgPJdwa88WlreA8=";
  };

  postPatch = ''
    sed -i 's/,<77//g' pyproject.toml # pythonRelaxDepsHook doesn't work for this for some reason
  '';

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
    pytest-qt
    mock
  ];

  postInstall = ''
    install -Dm 444 linux/plover.desktop $out/share/applications/plover.desktop
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  __structuredAttrs = true;

  build-system = [
    babel
    setuptools
    pyqt5
    wheel
  ];

  dependencies = [
    appdirs
    evdev
    pyqt5
    pyserial
    plover-stroke
    rtf-tokenize
    setuptools
    wcwidth
    python-xlib
  ];

  # Segfaults?!
  disabledTestPaths = [ "test/gui_qt/test_dictionaries_widget.py" ];
  dontWrapQtApps = true;

  optional-dependencies = {
    gui-qt = [
      pyqt5
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "plover" ];

  meta = {
    description = "OpenSteno Plover stenography software";
    homepage = "https://www.openstenoproject.org/plover/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      twey
      kovirobi
      pandapip1
      ShamrockLee
    ];

    platforms = lib.platforms.unix;
    mainProgram = "plover";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
