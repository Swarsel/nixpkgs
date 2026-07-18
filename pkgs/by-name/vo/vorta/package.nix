{
  lib,
  stdenv,
  fetchFromGitHub,
  borgbackup,
  makeFontsConf,
  python3Packages,
  qt6Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vorta";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "borgbase";
    repo = "vorta";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/60KVJGKNz3aouv5jzubFlz+AxPEbRDSv4ZO9MEi3V0=";
  };

  postPatch = ''
    substituteInPlace src/vorta/assets/metadata/com.borgbase.Vorta.desktop \
    --replace-fail com.borgbase.Vorta "com.borgbase.Vorta-symbolic"
  '';

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtsvg
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6Packages.qtwayland
  ];

  nativeCheckInputs = with python3Packages; [
    pytest-qt
    pytest-mock
    pytestCheckHook
    versionCheckHook
  ];

  preCheck =
    let
      fontsConf = makeFontsConf {
        fontDirectories = [ ];
      };
    in
    ''
      export HOME=$(mktemp -d)
      export FONTCONFIG_FILE=${fontsConf};
      # For tests/test_misc.py::test_autostart
      mkdir -p $HOME/.config/autostart
      export QT_PLUGIN_PATH="${qt6Packages.qtbase}/${qt6Packages.qtbase.qtPluginPrefix}"
      export QT_QPA_PLATFORM=offscreen
    '';

  postInstall = ''
    install -Dm644 src/vorta/assets/metadata/com.borgbase.Vorta.desktop $out/share/applications/com.borgbase.Vorta.desktop
    install -Dm644 src/vorta/assets/icons/icon.svg $out/share/pixmaps/com.borgbase.Vorta-symbolic.svg
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ borgbackup ]}
    )
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    packaging
    peewee
    platformdirs
    psutil
    pyqt6
    secretstorage
  ];

  disabledTestPaths = [
    # QObject::connect: No such signal QPlatformNativeInterface::systemTrayWindowChanged(QScreen*)    "tests/test_excludes.py"
    "tests/integration"
    "tests/unit"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # Darwin-only test
    "tests/network_manager/test_darwin.py"
  ];

  pyproject = true;

  meta = {
    description = "Desktop Backup Client for Borg";
    homepage = "https://vorta.borgbase.com/";
    changelog = "https://github.com/borgbase/vorta/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.linux;
    mainProgram = "vorta";
  };
})
