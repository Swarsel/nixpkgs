{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pyqt5,
  pytestCheckHook,
  qt5,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "anyqt";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "ales-erjavec";
    repo = "anyqt";
    tag = finalAttrs.version;
    hash = "sha256-iDUgu+x9rnpxpHzO7Rf2rJFXsheivrK7HI3FUbomkTU=";
  };

  nativeCheckInputs = [
    pyqt5
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    export QT_PLUGIN_PATH="${lib.getBin qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM=offscreen
  '';

  build-system = [ setuptools ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    "tests/test_qabstractitemview.py"
    "tests/test_qaction_set_menu.py"
    "tests/test_qactionevent_action.py"
    "tests/test_qfontdatabase_static.py"
    "tests/test_qpainter_draw_pixmap_fragments.py"
    "tests/test_qsettings.py"
    "tests/test_qstandarditem_insertrow.py"
    "tests/test_qtest.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "AnyQt" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "PyQt/PySide compatibility layer";
    homepage = "https://github.com/ales-erjavec/anyqt";
    changelog = "https://github.com/ales-erjavec/anyqt/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.gpl3Only ];
    maintainers = [ ];
  };
})
