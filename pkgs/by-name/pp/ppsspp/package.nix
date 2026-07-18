{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  copyDesktopItems,
  ffmpeg_6,
  glew,
  libffi,
  libsForQt5,
  libx11,
  libzip,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  python3,
  snappy,
  vulkan-loader,
  wayland,
  zlib,
  enableQt ? false,
  enableVulkan ? true,
  forceWayland ? false,
  useSystemFfmpeg ? false,
  useSystemSnappy ? true,
}:

let
  # experimental, see https://github.com/hrydgard/ppsspp/issues/13845
  vulkanWayland = enableVulkan && forceWayland;
  inherit (libsForQt5) qtbase qtmultimedia wrapQtAppsHook;
in
# Only SDL frontend needs to specify whether to use Wayland
assert forceWayland -> !enableQt;
stdenv.mkDerivation (finalAttrs: {
  pname =
    "ppsspp"
    + lib.optionalString enableQt "-qt"
    + lib.optionalString (!enableQt) "-sdl"
    + lib.optionalString forceWayland "-wayland";

  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "hrydgard";
    repo = "ppsspp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SWGlclmKXLLMYMmdfXyp4/g/mB4KKSIJdB5M9GW9HzI=";
    fetchSubmodules = true;
  };

  patches = lib.optionals useSystemFfmpeg [
    ./fix-ffmpeg-6.patch
  ];

  postPatch = ''
    substituteInPlace git-version.cmake --replace unknown ${finalAttrs.src.rev}
    substituteInPlace UI/NativeApp.cpp --replace /usr/share $out/share
  '';

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    python3
  ]
  ++ lib.optionals enableQt [ wrapQtAppsHook ];

  buildInputs = [
    SDL2
    libx11
    glew
    libzip
    zlib
  ]
  ++ lib.optionals useSystemFfmpeg [
    ffmpeg_6
  ]
  ++ lib.optionals useSystemSnappy [
    snappy
  ]
  ++ lib.optionals enableQt [
    qtbase
    qtmultimedia
  ]
  ++ lib.optionals enableVulkan [ vulkan-loader ]
  ++ lib.optionals vulkanWayland [
    wayland
    libffi
  ];

  cmakeFlags = [
    (lib.cmakeBool "HEADLESS" (!enableQt))
    (lib.cmakeBool "USE_SYSTEM_FFMPEG" useSystemFfmpeg)
    (lib.cmakeBool "USE_SYSTEM_LIBZIP" true)
    (lib.cmakeBool "USE_SYSTEM_SNAPPY" useSystemSnappy)
    (lib.cmakeBool "USE_WAYLAND_WSI" vulkanWayland)
    (lib.cmakeBool "USING_QT_UI" enableQt)
    (lib.cmakeFeature "OpenGL_GL_PREFERENCE" "GLVND")
  ];

  installPhase = lib.concatStringsSep "\n" (
    [
      "runHook preInstall"
    ]
    ++ [
      "mkdir -p $out/share/{applications,ppsspp/bin,icons}"
    ]
    ++ (
      if enableQt then
        [
          "install -Dm555 PPSSPPQt $out/share/ppsspp/bin/"
        ]
      else
        [
          "install -Dm555 PPSSPPHeadless $out/share/ppsspp/bin/"
          "makeWrapper $out/share/ppsspp/bin/PPSSPPHeadless $out/bin/ppsspp-headless"
          "install -Dm555 PPSSPPSDL $out/share/ppsspp/bin/"
        ]
    )
    ++ [
      "mv assets $out/share/ppsspp"
      "mv ../icons/hicolor $out/share/icons"
    ]
    ++ [
      "runHook postInstall"
    ]
  );

  postFixup =
    let
      wrapperArgs = lib.concatStringsSep " " (
        lib.optionals enableVulkan [
          "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}"
        ]
        ++ (
          if enableQt then
            [
              "\${qtWrapperArgs[@]}"
            ]
          else
            [
              "--set SDL_VIDEODRIVER ${if forceWayland then "wayland" else "x11"}"
            ]
        )
      );
      binToBeWrapped = if enableQt then "PPSSPPQt" else "PPSSPPSDL";
    in
    "makeWrapper $out/share/ppsspp/bin/${binToBeWrapped} $out/bin/ppsspp ${wrapperArgs}";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Emulator"
      ];

      comment = "Play PSP games on your computer";
      desktopName = "PPSSPP";
      exec = "ppsspp";
      icon = "ppsspp";
      name = "ppsspp";
    })
  ];

  dontWrapQtApps = true;

  meta = {
    description =
      "HLE Playstation Portable emulator, written in C++ ("
      + (if enableQt then "Qt" else "SDL + headless")
      + ")";

    longDescription = ''
      PPSSPP is a PSP emulator, which means that it can run games and other
      software that was originally made for the Sony PSP.

      The PSP had multiple types of software. The two most common are native PSP
      games on UMD discs and downloadable games (that were stored in the
      directory PSP/GAME on the "memory stick"). But there were also UMD Video
      discs, and PS1 games that could run in a proprietary emulator. PPSSPP does
      not run those.
    '';

    homepage = "https://www.ppsspp.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ppsspp";
  };
})
