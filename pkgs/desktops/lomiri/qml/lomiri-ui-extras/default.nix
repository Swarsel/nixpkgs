{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  cmake-extras,
  cups,
  exiv2,
  gitUpdater,
  lomiri-ui-toolkit,
  mesa,
  pam,
  pkg-config,
  qtbase,
  qtdeclarative,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lomiri-ui-extras";
  version = "0.8.2";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/lomiri-ui-extras";
    tag = finalAttrs.version;
    hash = "sha256-Y3p3VXltTg7tbVKjLdoBgL6yAlCdKBUEYzyHyqawxBg=";
  };

  postPatch = ''
    substituteInPlace modules/Lomiri/Components/Extras{,/{plugin,PamAuthentication}}/CMakeLists.txt \
      --replace-fail "\''${CMAKE_INSTALL_LIBDIR}/qt\''${QT_VERSION_MAJOR}/qml" "\''${CMAKE_INSTALL_PREFIX}/${qtbase.qtQmlPrefix}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cmake-extras
    cups
    exiv2
    pam
    qtbase
    qtdeclarative
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "ENABLE_QT6" (lib.strings.versionAtLeast qtbase.version "6"))
    (lib.cmakeFeature "CMAKE_CTEST_ARGUMENTS" (
      lib.concatStringsSep ";" [
        # Exclude tests
        "-E"
        (lib.strings.escapeShellArg "(${
          lib.concatStringsSep "|" [
            # Photo & PhotoImageProvider Randomly fail, unsure why
            "^tst_PhotoEditorPhoto"
          ]
        })")
      ]
    ))
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    mesa.llvmpipeHook # ShapeMaterial needs an OpenGL context: https://gitlab.com/ubports/development/core/lomiri-ui-toolkit/-/issues/35
    qtdeclarative # qmltestrunner
    xvfb-run
  ];

  checkInputs = [
    lomiri-ui-toolkit
  ];

  preCheck =
    let
      listToQtVar = suffix: lib.makeSearchPathOutput "bin" suffix;
    in
    ''
      export QT_PLUGIN_PATH=${listToQtVar qtbase.qtPluginPrefix [ qtbase ]}
      export QML2_IMPORT_PATH=${
        listToQtVar qtbase.qtQmlPrefix (
          [
            qtdeclarative
            lomiri-ui-toolkit
          ]
          ++ lomiri-ui-toolkit.propagatedBuildInputs
        )
      }
      export XDG_RUNTIME_DIR=$PWD
    '';

  dontWrapQtApps = true;
  # Parallelism breaks xvfb-run-launched script for QML tests
  enableParallelChecking = false;

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Lomiri UI Extra Components";

    longDescription = ''
      A collection of UI components that for various reasons can't be included in
      the main Lomiri UI toolkit - mostly because of the level of quality, lack of
      documentation and/or lack of automated tests.
    '';

    homepage = "https://gitlab.com/ubports/development/core/lomiri-ui-extras";
    changelog = "https://gitlab.com/ubports/development/core/lomiri-ui-extras/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lomiri ];
  };
})
