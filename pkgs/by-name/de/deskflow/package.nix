{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  gdk-pixbuf,
  gtest,
  lerc,
  libei,
  libnotify,
  libportal,
  libsysprof-capture,
  libx11,
  libxi,
  libxinerama,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxtst,
  ninja,
  nix-update-script,
  pkg-config,
  pugixml,
  python3,
  qt6,
  wayland,
  wayland-protocols,
  writableTmpDirAsHomeHook,
  xkeyboard_config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "deskflow";
  version = "1.26.0";

  src = fetchFromGitHub {
    owner = "deskflow";
    repo = "deskflow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XcSG47Ysjn+wrJH5DC/XXGXcneXcW7xIhAn6sguuv+s=";
  };

  postPatch = ''
    substituteInPlace src/lib/deskflow/unix/AppUtilUnix.cpp \
      --replace-fail "/usr/share/X11/xkb/rules/evdev.xml" "${xkeyboard_config}/share/X11/xkb/rules/evdev.xml"
    substituteInPlace deploy/linux/deploy.cmake \
      --replace-fail 'message(FATAL_ERROR "Unable to read file /etc/os-release")' 'set(RELEASE_FILE_CONTENTS "")'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    doxygen # docs
  ];

  buildInputs = [
    gtest
    libei
    libportal
    libx11
    libxkbfile
    libxinerama
    libxi
    libxrandr
    libxtst
    libxkbcommon
    pugixml
    gdk-pixbuf
    libnotify
    python3
    qt6.qtbase
    wayland-protocols
    qt6.qtwayland
    qt6.qtdeclarative
    qt6.qttools
    wayland
    libsysprof-capture
    lerc
  ];

  cmakeFlags = [
    "-DCMAKE_SKIP_RPATH=ON" # Avoid generating incorrect RPATH
    "-DSKIP_BUILD_TESTS=ON" # Perform unit tests in `checkPhase` manually, with one job at a time.
  ];

  doCheck = true;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkPhase = ''
    runHook preCheck

    export QT_QPA_PLATFORM=offscreen
    ctest --test-dir  "src/unittests" --output-on-failure
    ./bin/legacytests

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 ../README.md ../doc/user/configuration.md -t $out/share/doc/deskflow
  '';

  qtWrapperArgs = [
    "--set QT_QPA_PLATFORM_PLUGIN_PATH ${qt6.qtwayland}/${qt6.qtbase.qtPluginPrefix}/platforms"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Share one mouse and keyboard between multiple computers on Windows, macOS and Linux";
    homepage = "https://github.com/deskflow/deskflow";

    license = with lib.licenses; [
      gpl2Plus
      openssl
      mit # share/applications/org.deskflow.deskflow.desktop
    ];

    maintainers = with lib.maintainers; [ flacks ];
    platforms = lib.platforms.linux;
    mainProgram = "deskflow";
  };
})
