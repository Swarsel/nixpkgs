{
  lib,
  fetchFromGitHub,
  cmake,
  cubeb,
  curl,
  ffmpeg,
  gtk3,
  kddockwidgets,
  kdePackages,
  libaio,
  libbacktrace,
  libpcap,
  libwebp,
  libxrandr,
  llvmPackages,
  lz4,
  pkg-config,
  plutosvg,
  plutovg,
  qt6,
  sdl3,
  shaderc,
  soundtouch,
  strip-nondeterminism,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wrapGAppsHook3,
  zip,
  zstd,
}:

let
  pcsx2_patches = fetchFromGitHub {
    hash = "sha256-C5diPrIXvzOvskKQFjYWOfjQUkb/Omw2IN3K4b3nsK4=";
    owner = "PCSX2";
    repo = "pcsx2_patches";
    rev = "39c64ed2151155a9e7b9cc41129618c1ba0ad04f";
  };

  inherit (qt6)
    qtbase
    qtsvg
    qttools
    qtwayland
    wrapQtAppsHook
    ;
in
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "pcsx2";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "PCSX2";
    repo = "pcsx2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-85PZ7ZDoannmwoFeKM7hm7fQS1X2MPxAwm6k+Sa+bGc=";
    pname = "pcsx2-source";
  };

  patches = [
    ./remove-cubeb-vendor.patch
  ];

  postPatch = ''
    substituteInPlace cmake/Pcsx2Utils.cmake \
      --replace-fail 'set(PCSX2_GIT_TAG "")' 'set(PCSX2_GIT_TAG "${finalAttrs.src.tag}")'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    strip-nondeterminism
    wrapGAppsHook3
    wrapQtAppsHook
    zip
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    curl
    ffmpeg
    gtk3
    libaio
    libbacktrace
    libpcap
    libwebp
    libxrandr
    lz4
    qtbase
    qtsvg
    qttools
    qtwayland
    sdl3
    plutovg
    plutosvg
    kddockwidgets
    shaderc
    soundtouch
    vulkan-headers
    wayland
    zstd
    cubeb
  ];

  cmakeFlags = [
    (lib.cmakeBool "PACKAGE_MODE" true)
    (lib.cmakeBool "DISABLE_ADVANCE_SIMD" true)
    (lib.cmakeBool "USE_LINKED_FFMPEG" true)
  ];

  postInstall = ''
    install -Dm644 $src/pcsx2-qt/resources/icons/AppIcon64.png $out/share/icons/hicolor/64x64/apps/PCSX2.png
    install -Dm644 $src/.github/workflows/scripts/linux/pcsx2-qt.desktop $out/share/applications/PCSX2.desktop

    zip -jq $out/share/PCSX2/resources/patches.zip ${pcsx2_patches}/patches/*
    strip-nondeterminism $out/share/PCSX2/resources/patches.zip
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;

  qtWrapperArgs =
    let
      libs = lib.makeLibraryPath [
        vulkan-loader
        shaderc
      ];
    in
    [ "--prefix LD_LIBRARY_PATH : ${libs}" ];

  passthru = {
    inherit pcsx2_patches;
    updateScript.command = [ ./update.sh ];
  };

  meta = {
    description = "Playstation 2 emulator";

    longDescription = ''
      PCSX2 is an open-source PlayStation 2 (AKA PS2) emulator. Its purpose is
      to emulate the PS2 hardware, using a combination of MIPS CPU Interpreters,
      Recompilers and a Virtual Machine which manages hardware states and PS2
      system memory. This allows you to play PS2 games on your PC, with many
      additional features and benefits.
    '';

    homepage = "https://pcsx2.net";
    changelog = "https://github.com/PCSX2/pcsx2/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = with lib.maintainers; [
      _0david0mp
      govanify
      matteopacini
    ];

    platforms = lib.systems.inspect.patternLogicalAnd lib.systems.inspect.patterns.isLinux lib.systems.inspect.patterns.isx86_64;
    mainProgram = "pcsx2-qt";
    downloadPage = "https://github.com/PCSX2/pcsx2";
  };
})
