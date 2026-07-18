{
  lib,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  autoPatchelfHook,
  cmake,
  copyDesktopItems,
  glslang,
  gtk3,
  libuuid,
  llvmPackages_20,
  lz4,
  makeDesktopItem,
  ninja,
  pkg-config,
  python3,
  spirv-tools,
  symlinkJoin,
  unstableGitUpdater,
  vulkan-loader,
  wrapGAppsHook3,
}:

let
  vulkan-sdk = symlinkJoin {
    name = "vulkan-sdk";

    paths = [
      glslang
      spirv-tools
    ];
  };
in
llvmPackages_20.stdenv.mkDerivation {
  pname = "xenia-canary";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "xenia-canary";
    repo = "xenia-canary";
    rev = "9588ce244dc2684d1573736a717a5d234bf7c2bb";
    hash = "sha256-nQuBh4XOSSeIX51KLXLyv+gTk51I4/VNgSBrV835mBI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    python3
    pkg-config
    ninja
    cmake
    wrapGAppsHook3
    copyDesktopItems
    glslang
    spirv-tools
    llvmPackages_20.lld
    autoPatchelfHook
    alsa-lib
    libuuid
  ];

  buildInputs = [
    gtk3
    lz4
    SDL2
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=unused-result"
  ];

  buildPhase = ''
    runHook preBuild
    export VULKAN_SDK="${vulkan-sdk}"
    python3 xenia-build.py setup
    python3 xenia-build.py build --config=release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    find ./build/bin -mindepth 3 -maxdepth 3 -type f -executable -exec install -Dm755 {} -t $out/bin \;
    for width in 16 32 48 64 128 256; do
      install -Dm644 assets/icon/$width.png $out/share/icons/hicolor/''${width}x''${width}/apps/xenia-canary.png
    done
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Emulator"
      ];

      comment = "Xbox 360 Emulator Research Project";
      desktopName = "Xenia Canary";
      exec = "xenia_canary";
      genericName = "Xbox 360 Emulator";
      icon = "xenia-canary";
      keywords = [ "xbox" ];
      name = "xenia_canary";
      startupWMClass = "Xenia_canary";
    })
  ];

  dontConfigure = true;

  runtimeDependencies = [
    vulkan-loader
  ];

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "Xbox 360 Emulator Research Project";
    homepage = "https://github.com/xenia-canary/xenia-canary";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tuxy ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "xenia_canary";
  };
}
