{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  fetchpatch,
  gst_all_1,
  makeDesktopItem,
  mpv-unwrapped,
  ninja,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "anilibria-winmaclinux";
  version = "2.2.36";

  src = fetchFromGitHub {
    owner = "anilibria";
    repo = "anilibria-winmaclinux";
    tag = finalAttrs.version;
    hash = "sha256-2fwpLHEH1jlxl7r7QiVTHZniBO5k0GWaloNBynZJlTw=";
  };

  patches = [
    ./0001-disable-version-check.patch
    (fetchpatch {
      hash = "sha256-6/oXAObmXS+GKjjLNneMIj2gtKNvz6zHshWDYPv4agY=";
      name = "0002-fixed-qt6-folder-modal.patch";
      stripLen = 1;
      url = "https://github.com/anilibria/anilibria-winmaclinux/commit/adb4f7e5447d733fc3042f4bff25224ed726f3e6.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    qt6Packages.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtwebsockets
    qt6Packages.qtmultimedia
    mpv-unwrapped.dev
  ]
  ++ (with gst_all_1; [
    gst-plugins-bad
    gst-plugins-good
    gst-plugins-base
    gst-libav
    gstreamer
  ]);

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Qt"
        "Audio"
        "Video"
        "AudioVideo"
        "Player"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "AniLiberty";
      exec = finalAttrs.meta.mainProgram;
      genericName = "AniLiberty (ex AniLibria) desktop client";
      icon = "aniliberty";
      keywords = [ "anime" ];
      name = "AniLiberty";
      terminal = false;
    })
  ];

  qtWrapperArgs = [
    "--prefix GST_PLUGIN_PATH : ${
      (
        with gst_all_1;
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
          gst-plugins-bad
          gst-plugins-good
          gst-plugins-base
          gst-libav
          gstreamer
        ]
      )
    }"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    inherit (qt6Packages.qtbase.meta) platforms;
    description = "AniLiberty (ex AniLibria) cross platform desktop client, an anime theater for any computer you own";
    homepage = "https://github.com/anilibria/anilibria-winmaclinux";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
    mainProgram = "AniLiberty";
  };
})
