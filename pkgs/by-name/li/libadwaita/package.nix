{
  lib,
  stdenv,
  fetchFromGitLab,
  adwaita-icon-theme,
  appstream,
  desktop-file-utils,
  fribidi,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  meson,
  ninja,
  pkg-config,
  sassc,
  testers,
  vala,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libadwaita";
  version = "1.9.1";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "libadwaita";
    tag = finalAttrs.version;
    hash = "sha256-Oy3WcsymNbbmAacm5hEOrorI1wKXjSp063mh4jCJRAE=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    gi-docgen
    meson
    ninja
    pkg-config
    sassc
    vala
    gobject-introspection
    desktop-file-utils # for validate-desktop-file
  ];

  buildInputs = [
    appstream
    fribidi
  ];

  propagatedBuildInputs = [
    gtk4
  ];

  mesonFlags = [
    "-Ddocumentation=true"
  ]
  ++ lib.optionals (!finalAttrs.finalPackage.doCheck) [
    "-Dtests=false"
  ];

  # Tests had to be disabled on Darwin because test-button-content fails
  #
  # not ok /Adwaita/ButtonContent/style_class_button - Gdk-FATAL-CRITICAL:
  # gdk_macos_monitor_get_workarea: assertion 'GDK_IS_MACOS_MONITOR (self)' failed
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    adwaita-icon-theme
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    testEnvironment=(
      # Disable portal since we cannot run it in tests.
      ADW_DISABLE_PORTAL=1

      # AdwSettings needs to be initialized from “org.gnome.desktop.interface” GSettings schema when portal is not used for color scheme.
      # It will not actually be used since the “color-scheme” key will only have been introduced in GNOME 42, falling back to detecting theme name.
      # See adw_settings_constructed function in https://gitlab.gnome.org/GNOME/libadwaita/commit/60ec69f0a5d49cad8a6d79e4ecefd06dc6e3db12
      #
      # The "Validate docs" test looks for various GIR dependencies, thus preserve the existing paths.
      "XDG_DATA_DIRS=$XDG_DATA_DIRS:${glib.getSchemaDataDirPath gsettings-desktop-schemas}"

      # Tests need a cache directory
      "HOME=$TMPDIR"
    )
    env "''${testEnvironment[@]}" ${lib.optionalString (!stdenv.hostPlatform.isDarwin) "xvfb-run"} \
      meson test --timeout-multiplier 10 --print-errorlogs

    runHook postCheck
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"

    # Put all resources related to demo app into devdoc output.
    for d in applications icons metainfo; do
      moveToOutput "share/$d" "$devdoc"
    done
  '';

  depsBuildBuild = [
    pkg-config
  ];

  outputBin = "devdoc"; # demo app
  separateDebugInfo = true;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };

    updateScript = gnome.updateScript {
      packageName = finalAttrs.pname;
    };
  };

  meta = {
    description = "Library to help with developing UI for mobile devices using GTK/GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/libadwaita";
    changelog = "https://gitlab.gnome.org/GNOME/libadwaita/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
    mainProgram = "adwaita-1-demo";
    pkgConfigModules = [ "libadwaita-1" ];
    teams = [ lib.teams.gnome ];
  };
})
