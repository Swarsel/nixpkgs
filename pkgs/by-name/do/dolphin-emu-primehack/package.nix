{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  # linux-only
  alsa-lib,
  bluez,
  cmake,
  # buildInputs
  curl,
  enet,
  fetchpatch2,
  ffmpeg,
  fmt_9,
  gettext,
  # darwin-only
  hidapi,
  libGL,
  libGLU,
  libao,
  libevdev,
  libpng,
  libpthread-stubs,
  libpulseaudio,
  libsm,
  libusb1,
  libxdmcp,
  libxext,
  libxinerama,
  libxrandr,
  libxxf86vm,
  mbedtls,
  miniupnpc,
  nix-update-script,
  openal,
  # nativeBuildInputs
  pkg-config,
  portaudio,
  qt6,
  readline,
  sfml,
  soundtouch,
  # passthru
  testers,
  udev,
  vulkan-loader,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dolphin-emu-primehack";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "shiiion";
    repo = "dolphin";
    tag = finalAttrs.version;
    hash = "sha256-/9AabEJ2ZOvHeSGXWRuOucmjleBMRcJfhX+VDeldbgo=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-QEG0p+AzrExWrOxL0qRPa+60GlL0DlLyVBrbG6pGuog=";
      url = "https://github.com/dolphin-emu/dolphin/commit/8edef722ce1aae65d5a39faf58753044de48b6e0.patch?full_index=1";
    })
  ];

  # - Allow Dolphin to use nix-provided libraries instead of building them
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'DISTRIBUTOR "None"' 'DISTRIBUTOR "NixOS"'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'if(NOT APPLE)' 'if(true)' \
      --replace-fail 'if(LIBUSB_FOUND AND NOT APPLE)' 'if(LIBUSB_FOUND)'
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    curl
    enet
    ffmpeg
    fmt_9
    gettext
    libGL
    libGLU
    libsm
    libxdmcp
    libxext
    libxinerama
    libxrandr
    libxxf86vm
    libao
    libpthread-stubs
    libpulseaudio
    libusb1
    mbedtls
    miniupnpc
    openal
    portaudio
    qt6.qtbase
    qt6.qtsvg
    readline
    SDL2
    sfml
    soundtouch
    xz
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    bluez
    libevdev
    udev
    vulkan-loader
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    hidapi
    libpng
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SHARED_ENET" true)
    (lib.cmakeBool "ENABLE_LTO" true)
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeBool "OSX_USE_DEFAULT_SEARCH_PATH" true)
  ];

  postInstall = ''
    mv $out/bin/dolphin-emu $out/bin/dolphin-emu-primehack
    mv $out/bin/dolphin-emu-nogui $out/bin/dolphin-emu-primehack-nogui
    mv $out/share/applications/dolphin-emu.desktop $out/share/applications/dolphin-emu-primehack.desktop
    mv $out/share/icons/hicolor/256x256/apps/dolphin-emu.png $out/share/icons/hicolor/256x256/apps/dolphin-emu-primehack.png
    substituteInPlace $out/share/applications/dolphin-emu-primehack.desktop \
      --replace-fail 'dolphin-emu' 'dolphin-emu-primehack' \
      --replace-fail 'Dolphin Emulator' 'PrimeHack'
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -D $src/Data/51-usb-device.rules $out/etc/udev/rules.d/51-usb-device.rules
  '';

  doInstallCheck = true;

  qtWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
    # https://bugs.dolphin-emu.org/issues/11807
    # The .desktop file should already set this, but Dolphin may be launched in other ways
    "--set QT_QPA_PLATFORM xcb"
  ];

  passthru = {
    tests = {
      version = testers.testVersion {
        version = "v${finalAttrs.version}";
        command = "dolphin-emu-primehack-nogui --version";
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Gamecube/Wii/Triforce emulator for x86_64 and ARMv8";
    homepage = "https://github.com/shiiion/dolphin";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
