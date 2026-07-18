{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  cpp-utilities,
  cppunit,
  iconv,
  kdePackages,
  syncthing,
  versionCheckHook,
  xdg-utils,
  /*
    It is possible to set via this option an absolute exec path that will be
    written to the `~/.config/autostart/syncthingtray.desktop` file generated
    during runtime. Alternatively, one can edit the desktop file themselves after
    it is generated See:
    https://github.com/NixOS/nixpkgs/issues/199596#issuecomment-1310136382
  */
  autostartExecPath ? "syncthingtray",
  jsSupport ? true,
  kioPluginSupport ? stdenv.hostPlatform.isLinux,
  plasmoidSupport ? stdenv.hostPlatform.isLinux,
  systemdSupport ? stdenv.hostPlatform.isLinux,
  webviewSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "syncthingtray";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "Martchus";
    repo = "syncthingtray";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VU47ncrgY00LJTrM4GKMDbhtFtBrcTwakhNCbcucoFo=";
  };

  nativeBuildInputs = [
    kdePackages.wrapQtAppsHook
    cmake
    kdePackages.qttools
    # Although these are test dependencies, we add them anyway so that we test
    # whether the test units compile. On Darwin we don't run the tests but we
    # still build them.
    cppunit
    syncthing
  ]
  ++ lib.optionals plasmoidSupport [ kdePackages.extra-cmake-modules ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtsvg
    cpp-utilities
    kdePackages.qtutilities
    boost
    kdePackages.qtforkawesome
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ iconv ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ kdePackages.qtwayland ]
  ++ lib.optionals webviewSupport [ kdePackages.qtwebengine ]
  ++ lib.optionals jsSupport [ kdePackages.qtdeclarative ]
  ++ lib.optionals kioPluginSupport [ kdePackages.kio ]
  ++ lib.optionals plasmoidSupport [ kdePackages.libplasma ];

  cmakeFlags = [
    (lib.cmakeFeature "QT_PACKAGE_PREFIX" "Qt${lib.versions.major kdePackages.qtbase.version}")
    (lib.cmakeFeature "KF_PACKAGE_PREFIX" "KF${lib.versions.major kdePackages.qtbase.version}")
    (lib.cmakeBool "BUILD_TESTING" (finalAttrs.doCheck or false))
    # See https://github.com/Martchus/syncthingtray/issues/208
    (lib.cmakeBool "EXCLUDE_TESTS_FROM_ALL" false)
    (lib.cmakeFeature "AUTOSTART_EXEC_PATH" autostartExecPath)
    # See https://github.com/Martchus/syncthingtray/issues/42
    (lib.cmakeFeature "QT_PLUGIN_DIR" "${placeholder "out"}/${kdePackages.qtbase.qtPluginPrefix}")
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "NO_PLASMOID" (!plasmoidSupport))
    (lib.cmakeBool "NO_FILE_ITEM_ACTION_PLUGIN" (!kioPluginSupport))
    (lib.cmakeBool "SYSTEMD_SUPPORT" systemdSupport)
    (lib.cmakeFeature "WEBVIEW_PROVIDER" (if webviewSupport then "webengine" else "none"))
  ];

  # syncthing server seems to hang on darwin, causing tests to fail.
  doCheck = !stdenv.hostPlatform.isDarwin;

  preCheck = ''
    export QT_QPA_PLATFORM=offscreen
    export QT_PLUGIN_PATH="${lib.getBin kdePackages.qtbase}/${kdePackages.qtbase.qtPluginPrefix}"
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # put the app bundle into the proper place /Applications instead of /bin
    mkdir -p $out/Applications
    mv $out/bin/syncthingtray.app $out/Applications
    # Make binary available in PATH like on other platforms
    ln -s $out/Applications/syncthingtray.app/Contents/MacOS/syncthingtray $out/bin/syncthingtray
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ xdg-utils ]}"
  ];

  meta = {
    description = "Tray application and Dolphin/Plasma integration for Syncthing";
    homepage = "https://github.com/Martchus/syncthingtray";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "syncthingtray";
  };
})
