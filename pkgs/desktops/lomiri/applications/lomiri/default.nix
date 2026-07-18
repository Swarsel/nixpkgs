{
  lib,
  stdenv,
  fetchFromGitLab,
  bash,
  biometryd,
  boost,
  cmake,
  cmake-extras,
  coreutils,
  dbus,
  dbus-test-runner,
  deviceinfo,
  fetchpatch,
  geonames,
  gitUpdater,
  glib,
  glm,
  gnome-desktop,
  gsettings-qt,
  gtk3,
  hfd-service,
  libevdev,
  libqtdbusmock,
  libqtdbustest,
  libusermetrics,
  libuuid,
  lightdm_qt,
  linkFarm,
  lomiri-api,
  lomiri-app-launch,
  lomiri-download-manager,
  lomiri-indicator-datetime,
  lomiri-indicator-network,
  lomiri-notifications,
  lomiri-schemas,
  lomiri-settings-components,
  lomiri-system-settings-unwrapped,
  lomiri-telephony-service,
  lomiri-thumbnailer,
  lomiri-ui-toolkit,
  maliit-keyboard,
  mir_2_15,
  nixos-icons,
  nixosTests,
  pam,
  pkg-config,
  properties-cpp,
  protobuf,
  python3,
  qmenumodel,
  qtbase,
  qtdeclarative,
  qtmir,
  qtmultimedia,
  qtsvg,
  replaceVars,
  wrapGAppsHook3,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lomiri";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/lomiri";
    tag = finalAttrs.version;
    hash = "sha256-blXEfDauwtDH+0OdUx0vAR+8lnAGrREssqjsBNmvomk=";
  };

  patches = [
    # Fix broken multimedia suspend due to missing media-hub
    (fetchpatch {
      hash = "sha256-9mvkILrkig18fAw5KyA2+5vXup6Le7X0blgY0PJ2Trc=";
      name = "2012-lomiri-dont-suspend-apps.patch";
      url = "https://salsa.debian.org/ubports-team/lomiri/-/raw/1d6e83446f69299d1206927c2adbf78470ba27ec/debian/patches/2012_no-app-suspension-on-Debian+Ubuntu-proper.patch";
    })

    # Fix convergence on some tablets
    (fetchpatch {
      hash = "sha256-pQYIa8U0gEFdwZBuWMp8nL5j2HPSivMrsuKUC9scKg0=";
      name = "1013-lomiri-fix-convergence-on-high-resolution-tablets.patch";
      url = "https://salsa.debian.org/ubports-team/lomiri/-/raw/4d4904b728a3e66706c756f911ddc79b01f863a2/debian/patches/1013_fix-convergence-on-high-resolution-tablets.patch";
    })

    # Make greeter behave nicer & more Wayland-native
    (fetchpatch {
      hash = "sha256-aEId3UDqH1iUi9gV5IpW/5S5rke93UyZVr0jWlNYnOU=";
      name = "2014-lomiri-greeter-wrapper-on-wayland.patch";
      url = "https://salsa.debian.org/ubports-team/lomiri/-/raw/e655e14c7d420021193e37debd3e7da620b45429/debian/patches/2014_lomiri-greeter-wrapper-on-wayland.patch";
    })
    (fetchpatch {
      hash = "sha256-fnTEVQnOBQVd95ucs+iDMcQFOevfQ8dckQg0PrtL/A0=";
      name = "2015-lomiri-greeter-use-wayland.patch";
      url = "https://salsa.debian.org/ubports-team/lomiri/-/raw/2f5acfa085c901359bf6f6cccbce36d7e2981555/debian/patches/2015_lomiri-greeter-use-wayland.patch";
    })

    # Reduce desyncing of cursor
    (fetchpatch {
      hash = "sha256-FYWRHt3//gm3jT9dr35tH4PlZssMMA/zBhjkszgqTYo=";
      name = "1005-lomiri-cursor-always-follow-cursor-position-from-mir.patch";
      url = "https://salsa.debian.org/ubports-team/lomiri/-/raw/f3ba943006f5469a8a7aa24f232d6383afb3bc74/debian/patches/1005_cursor-always-follow-cursor-position-from-mir.patch";
    })

    # Undo start-here integration & uglier colours for launcher
    (fetchpatch {
      hash = "sha256-9YRWMV+1UT+EQd9Uq1+6enNzz+HDlSt3LTPM1BKJxiE=";
      name = "0001-lomiri-LauncherPanel-Use-Lomiri-upstream-home-logo-and-home-background-color.patch";
      url = "https://gitlab.com/ubports/development/core/lomiri/-/commit/defaabfaf4818ee6b618c97b34acf5e0ed2ebb2e.patch";
    })

    # Compatibility with newer lomiri-api
    # Remove when version > 0.5.0
    (fetchpatch {
      hash = "sha256-1mPDtitMpktuvLs3Zn+6pCaMGTwGvIglGBdrm4Y8QwA=";
      name = "0002-lomiri-Adjust-to-newer-lomiri-api.patch";
      url = "https://gitlab.com/ubports/development/core/lomiri/-/commit/26cbfa458766df406ed7d2c351ec84522371b083.patch";
    })

    ./9901-lomiri-Disable-Wizard.patch
    (replaceVars ./9902-Layout-fallback-file.patch {
      nixosLayoutFile = "/etc/" + finalAttrs.finalPackage.passthru.etcLayoutsFile;
    })
  ];

  postPatch = ''
    # Written with a different qtmir branch in mind, but different branch breaks compat with some patches
    substituteInPlace CMakeLists.txt \
      --replace-fail 'qt5mir2server' 'qtmirserver'

    # Need to replace prefix
    substituteInPlace data/systemd-user/CMakeLists.txt \
      --replace-fail 'pkg_get_variable(SYSTEMD_USER_UNIT_DIR systemd systemd_user_unit_dir)' 'pkg_get_variable(SYSTEMD_USER_UNIT_DIR systemd systemd_user_unit_dir DEFINE_VARIABLES prefix=''${CMAKE_INSTALL_PREFIX})'

    # Don't embed full paths into regular desktop files (but do embed them into lightdm greeter one)
    substituteInPlace data/{indicators-client,lomiri}.desktop.in.in \
      --replace-fail '@CMAKE_INSTALL_FULL_BINDIR@/' ""

    # Exclude tests that don't compile (Mir headers these relied on were removed in mir 2.9)
    # fatal error: mirtest/mir/test/doubles/stub_surface.h: No such file or directory
    substituteInPlace tests/mocks/CMakeLists.txt \
      --replace-fail 'add_subdirectory(QtMir/Application)' ""

    # Seems like the Debian patch that added this didn't read the lightdm greeter entry properly, so everything gets passed twice
    substituteInPlace data/lomiri-greeter.desktop.in.in \
      --replace-fail 'lomiri-greeter-wrapper @CMAKE_INSTALL_FULL_BINDIR@/lomiri --mode=greeter' 'lomiri-greeter-wrapper'
    substituteInPlace data/lomiri-greeter-wrapper \
      --replace-fail 'LOMIRI_BINARY:-lomiri' "LOMIRI_BINARY:-$out/bin/lomiri"

    # Look up default wallpaper in current system
    substituteInPlace plugins/Utils/constants.cpp \
      --replace-fail '/usr/share/backgrounds' '/run/current-system/sw/share/wallpapers'
  ''
  + lib.optionalString finalAttrs.finalPackage.doCheck ''
    patchShebangs tests/whitespace/check_whitespace.py
  '';

  nativeBuildInputs = [
    cmake
    dbus-test-runner
    glib # populates GSETTINGS_SCHEMAS_PATH
    pkg-config
    wrapGAppsHook3 # XDG_DATA_DIRS wrapper flags for schemas
    wrapQtAppsHook
  ];

  buildInputs = [
    bash
    boost
    cmake-extras
    dbus
    dbus-test-runner
    deviceinfo
    geonames
    glib
    glm
    gnome-desktop
    gsettings-qt
    gtk3
    libevdev
    libusermetrics
    libuuid
    lightdm_qt
    lomiri-api
    lomiri-app-launch
    lomiri-download-manager
    lomiri-indicator-datetime
    lomiri-indicator-network
    lomiri-schemas
    lomiri-system-settings-unwrapped
    lomiri-ui-toolkit
    maliit-keyboard
    mir_2_15
    pam
    properties-cpp
    protobuf
    qmenumodel
    qtbase
    qtdeclarative
    qtmir
    qtsvg

    # QML import path
    biometryd
    hfd-service
    lomiri-notifications
    lomiri-settings-components
    lomiri-telephony-service
    lomiri-thumbnailer
    qtmultimedia
  ];

  cmakeFlags = [
    (lib.cmakeBool "NO_TESTS" (!finalAttrs.finalPackage.doCheck))
    (lib.cmakeBool "WITH_MIR2" true)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeCheckInputs = [ (python3.withPackages (ps: with ps; [ python-dbusmock ])) ];

  checkInputs = [
    libqtdbustest
    libqtdbusmock
  ];

  preCheck = ''
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
    export XDG_DATA_DIRS=${libqtdbusmock}/share
  '';

  postInstall = ''
    install -Dm755 ../data/lomiri-greeter-wrapper $out/bin/lomiri-greeter-wrapper
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapQtApp $out/bin/lomiri
    wrapQtApp $out/bin/indicators-client
    wrapQtApp $out/bin/lomiri-mock-indicator-service

    wrapProgram $out/bin/lomiri-greeter-wrapper \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          dbus
          deviceinfo
          glib
        ]
      } \
      --set LOMIRI_BINARY "$out/bin/lomiri"

    wrapProgram $out/libexec/Xwayland.lomiri \
      --prefix PATH : ${lib.makeBinPath [ deviceinfo ]}

    wrapProgram $out/libexec/lomiri-systemd-wrapper \
      --prefix PATH : ${lib.makeBinPath [ dbus ]}
  '';

  # Need its flags
  dontWrapGApps = true;
  # Manually calling, to avoid double & unnecessary wrapping
  dontWrapQtApps = true;

  passthru = {
    etcLayoutsFile = "lomiri/keymaps";

    greeter = linkFarm "lomiri-greeter" [
      {
        name = "lomiri-greeter.desktop";
        path = "${finalAttrs.finalPackage}/share/lightdm/greeters/lomiri-greeter.desktop";
      }
    ];

    tests = nixosTests.lomiri;
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Shell of the Lomiri Operating environment";

    longDescription = ''
      Shell of the Lomiri Operating environment optimized for touch based human-machine interaction, but also supporting
      convergence (i.e. switching between tablet/phone and desktop mode).

      Lomiri is the user shell driving Ubuntu Touch based mobile devices.
    '';

    homepage = "https://lomiri.com/";
    changelog = "https://gitlab.com/ubports/development/core/lomiri/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "lomiri";
    teams = [ lib.teams.lomiri ];
  };
})
