{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  gnutls,
  libarchive,
  libtasn1,
  liburing,
  libusb1,
  nix-update-script,
  pkg-config,
  qt6,
  testers,
  wrapGAppsHook4,
  writeShellScriptBin,
  xz,
  zstd,
  enableTelemetry ? false,
  enableUring ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpi-imager";
  version = "2.0.10";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-imager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k6ld7TWCj8JzLJG9ph7hKXvR1nkHt0fJqlGSs+NqnR0=";
  };

  patches = [ ./remove-vendoring.patch ];

  postPatch = ''
    substituteInPlace debian/com.raspberrypi.rpi-imager.desktop \
      --replace-fail "/usr/bin/" ""

    substituteInPlace src/CMakeLists.txt \
      --replace-fail 'qt_add_lupdate(TS_FILES ''${TRANSLATIONS} SOURCE_TARGETS ''${PROJECT_NAME} OPTIONS -no-obsolete -locations none)' ""
  '';

  nativeBuildInputs =
    let
      # Fool upstream's cmake lsblk check a bit
      fake-lsblk = writeShellScriptBin "lsblk" ''
        echo "our lsblk has --json support but it doesn't work in our sandbox"
      '';

      # Upstream uses `git describe` to define a `IMAGER_VERSION` CMake variable,
      # and we fool it to take a version from a fake `git` executable.
      fake-git = writeShellScriptBin "git" ''
        echo "v${finalAttrs.version}"
      '';
    in
    [
      cmake
      fake-git
      fake-lsblk
      pkg-config
      qt6.wrapQtAppsHook
      wrapGAppsHook4
    ];

  buildInputs = [
    curl
    gnutls
    libarchive
    libtasn1
    libusb1
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qttools
    xz
    zstd
  ]
  ++ lib.optional enableUring liburing
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.qtwayland
  ];

  cmakeFlags = [
    # Isn't relevant for Nix
    (lib.cmakeBool "ENABLE_CHECK_VERSION" false)
    (lib.cmakeBool "ENABLE_TELEMETRY" enableTelemetry)
    # Disable fetching external data files
    (lib.cmakeBool "GENERATE_CAPITAL_CITIES" false)
    (lib.cmakeBool "GENERATE_COUNTRIES_FROM_REGDB" false)
    (lib.cmakeBool "GENERATE_TIMEZONES_FROM_IANA" false)
  ];

  env.LANG = "C.UTF-8";

  preConfigure = ''
    cd src
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;

  qtWrapperArgs = [
    "--unset QT_QPA_PLATFORMTHEME"
    "--unset QT_STYLE_OVERRIDE"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "QT_QPA_PLATFORM=offscreen rpi-imager --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Raspberry Pi Imaging Utility";
    homepage = "https://github.com/raspberrypi/rpi-imager/";
    changelog = "https://github.com/raspberrypi/rpi-imager/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      anthonyroussel
      agustinmista
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    # could not find xz
    badPlatforms = lib.platforms.darwin;
    mainProgram = "rpi-imager";
  };
})
