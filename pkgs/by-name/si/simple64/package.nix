{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  SDL2_net,
  cmake,
  copyDesktopItems,
  hidapi,
  libpng,
  makeDesktopItem,
  makeWrapper,
  ninja,
  pkg-config,
  qt6,
  vulkan-loader,
  writeShellScriptBin,
  zlib,
}:

let
  cheats-json = fetchurl {
    hash = "sha256-rS/4Mdi+18C2ywtM5nW2XaJkC1YnKZPc4YdQ3mCfESU=";
    url = "https://raw.githubusercontent.com/simple64/cheat-parser/87963b7aca06e0d4632b66bc5ffe7d6b34060f4f/cheats.json";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "simple64";
  version = "2024.12.1";

  src = fetchFromGitHub {
    owner = "simple64";
    repo = "simple64";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rvoUyvhpbibXbAreu6twTeeVRTCbhJiJuyKaJz0uT5k=";
  };

  patches = [
    ./dont-use-vosk-and-discord.patch
    ./add-official-server-error-message.patch
  ];

  postPatch = ''
    cp ${cheats-json} cheats.json
  '';

  strictDeps = true;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    cmake
    ninja
    pkg-config
    makeWrapper
    copyDesktopItems
    # fake git command for version info generator
    (writeShellScriptBin "git" "echo ${finalAttrs.src.rev}")
  ];

  buildInputs = [
    zlib
    libpng
    SDL2
    SDL2_net
    hidapi
    qt6.qtbase
    qt6.qtwebsockets
    qt6.qtwayland
  ];

  buildPhase = ''
    runHook preBuild

    sh build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/simple64 $out/bin
    cp -r simple64/* $out/share/simple64

    install -Dm644 ./simple64-gui/icons/simple64.svg -t $out/share/icons/hicolor/scalable/apps/

    patchelf $out/share/simple64/simple64-gui \
      --add-needed libvulkan.so.1 --add-rpath ${lib.makeLibraryPath [ vulkan-loader ]}

    ln -s $out/share/simple64/simple64-gui $out/bin/simple64-gui

    runHook postInstall
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Emulator"
      ];

      desktopName = "simple64";
      exec = "simple64-gui";
      genericName = "Nintendo 64 Emulator";
      icon = "simple64";
      mimeTypes = [ "application/x-n64-rom" ];
      name = "simple64";
      terminal = false;
    })
  ];

  dontUseCmakeConfigure = true;

  meta = {
    description = "Easy to use N64 emulator";
    homepage = "https://simple64.github.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.platforms.linux;
    mainProgram = "simple64-gui";
  };
})
