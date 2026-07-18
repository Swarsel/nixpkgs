{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  copyDesktopItems,
  desktopToDarwinBundle,
  libglvnd,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxxf86vm,
  makeDesktopItem,
  mpv-unwrapped,
  pkg-config,
  wayland,
  wayland-protocols,
  waylandSupport ? false,
}:

buildGoModule (finalAttrs: {
  pname = "supersonic" + lib.optionalString waylandSupport "-wayland";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "dweymouth";
    repo = "supersonic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jKmkj7Y3D2Af7XNOkLY3sknOelvId649NZXpu/fU7ko=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = [
    libglvnd
    mpv-unwrapped
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxxf86vm
    libx11
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && !waylandSupport) [
    libxrandr
    libxinerama
    libxcursor
    libxi
    libxext
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && waylandSupport) [
    wayland
    wayland-protocols
    libxkbcommon
  ];

  vendorHash = "sha256-Qg5OWg+iFcGuD8E3/7YwmmciiRGdUFNSHLrEAaqRmnQ=";

  postInstall = ''
    for dimension in 128 256 512;do
        dimensions=''${dimension}x''${dimension}
        mkdir -p $out/share/icons/hicolor/$dimensions/apps
        cp res/appicon-$dimension.png $out/share/icons/hicolor/$dimensions/apps/${finalAttrs.meta.mainProgram}.png
    done
  ''
  + lib.optionalString waylandSupport ''
    mv $out/bin/supersonic $out/bin/${finalAttrs.meta.mainProgram}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Supersonic" + lib.optionalString waylandSupport " (Wayland)";
      exec = finalAttrs.meta.mainProgram;
      genericName = "Subsonic Client";
      icon = finalAttrs.meta.mainProgram;
      name = finalAttrs.meta.mainProgram;
      type = "Application";
    })
  ];

  # go-glfw doesn't support both X11 and Wayland in single build
  tags = [ "migrated_fynedo" ] ++ lib.optionals waylandSupport [ "wayland" ];

  meta = {
    description = "Lightweight cross-platform desktop client for Subsonic music servers";
    homepage = "https://github.com/dweymouth/supersonic";
    changelog = "https://github.com/dweymouth/supersonic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      zane
      sochotnicky
      toasteruwu
    ];

    platforms = lib.platforms.linux ++ lib.optionals (!waylandSupport) lib.platforms.darwin;
    mainProgram = "supersonic" + lib.optionalString waylandSupport "-wayland";
  };
})
