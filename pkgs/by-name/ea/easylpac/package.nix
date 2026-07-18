{
  lib,
  fetchFromGitHub,
  buildGoModule,
  copyDesktopItems,
  gtk3,
  libglvnd,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  lpac,
  makeDesktopItem,
  pkg-config,
  wrapGAppsHook3,
}:

buildGoModule rec {
  pname = "easylpac";
  version = "0.8.0.3";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    tag = version;
    hash = "sha256-q76p0BqrG8opuTClYKLfmM5hdziJIrZCwQmg2NkzW/E=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libglvnd
    libxxf86vm
    libx11
    libxrandr
    libxinerama
    libxcursor
    libxi
    libxext
  ];

  vendorHash = "sha256-52I8hlnoHPhygwr0dxDP50X2A7Gsh0v/0SGQFH3FG/8=";

  postInstall = ''
    install -Dm644 assets/icon64.png "$out/share/icons/hicolor/64x64/apps/EasyLPAC.png"
    install -Dm644 assets/icon128.png "$out/share/icons/hicolor/128x128/apps/EasyLPAC.png"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ lpac ]}
    )
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "GUI frontend for lpac, a C-based eUICC LPA";
      desktopName = "EasyLPAC";
      exec = "EasyLPAC";
      icon = "EasyLPAC";
      name = "EasyLPAC";
    })
  ];

  meta = {
    description = "GUI frontend for lpac, a C-based eUICC LPA";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stargate01 ];
    platforms = lib.platforms.unix;
    mainProgram = "EasyLPAC";
  };
}
