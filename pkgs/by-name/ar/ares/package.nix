{
  lib,
  stdenv,
  alsa-lib,
  apple-sdk,
  cmake,
  fetchzip,
  gtk3,
  gtksourceview3,
  libGL,
  libGLU,
  libao,
  libpulseaudio,
  librashader,
  libretro-shaders-slang,
  libx11,
  libxv,
  moltenvk,
  ninja,
  openal,
  pkg-config,
  replaceVars,
  sdl3,
  udev,
  vulkan-loader,
  wrapGAppsHook3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ares";
  version = "148";

  src = fetchzip {
    url = "https://github.com/ares-emulator/ares/releases/download/v${finalAttrs.version}/ares-source.tar.gz";
    hash = "sha256-LXLt4hYjpnLrzu+0dLfXr4lEF7drZwSRjgaCAaD79+g=";
    stripRoot = false;
  };

  patches = [
    (replaceVars ./darwin-build-fixes.patch {
      sdkVersion = apple-sdk.version;
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = [
    sdl3
    libao
    librashader
    vulkan-loader
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    moltenvk
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    gtk3
    gtksourceview3
    libGL
    libGLU
    libx11
    libxv
    libpulseaudio
    openal
    udev
  ];

  cmakeFlags = [
    (lib.cmakeBool "ARES_BUILD_LOCAL" false)
    (lib.cmakeBool "ARES_SKIP_DEPS" true)
    (lib.cmakeBool "ARES_BUILD_OFFICIAL" true)
  ];

  postInstall =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir $out/Applications
        cp -a desktop-ui/ares.app $out/Applications/ares.app
        # Shaders directory is already populated with Metal shaders, so can't simply symlink the slang shaders directory itself
        for f in ${libretro-shaders-slang}/share/libretro/shaders/shaders_slang/*; do
          ln -s "$f" $out/Applications/ares.app/Contents/Resources/Shaders/
        done
      ''
    else
      ''
        ln -s ${libretro-shaders-slang}/share/libretro $out/share/libretro
      '';

  postFixup =
    if stdenv.hostPlatform.isDarwin then
      ''
        install_name_tool \
          -add_rpath ${librashader}/lib \
          -add_rpath ${moltenvk}/lib \
          $out/Applications/ares.app/Contents/MacOS/ares
      ''
    else
      ''
        patchelf $out/bin/.ares-wrapped \
          --add-rpath ${
            lib.makeLibraryPath [
              librashader
              vulkan-loader
            ]
          }
      '';

  meta = {
    description = "Open-source multi-system emulator with a focus on accuracy and preservation";
    homepage = "https://ares-emu.net";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ nadiaholmquist ];
    platforms = lib.platforms.unix;
    mainProgram = "ares";
  };
})
