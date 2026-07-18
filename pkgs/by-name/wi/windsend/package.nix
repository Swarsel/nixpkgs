{
  lib,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  flutter341,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxtst,
  makeDesktopItem,
  sqlite,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "windsend";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "doraemonkeys";
    repo = "WindSend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r3D6Uj8buMceqXov6An+OxgOTcNFrX5PwxhphtbeUv0=";
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
  ];

  buildInputs = [
    libx11
    libxcursor
    libxrandr
    libxinerama
    libxi
    libxext
    libxtst
    sqlite
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";

  postInstall = ''
    install -Dm644 ../../app_icon/web/icon-512.png $out/share/icons/hicolor/512x512/apps/windsend.png
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "WindSend";
      exec = "WindSend";
      icon = "windsend";
      name = "windsend";
    })
  ];

  dontUseCmakeConfigure = true;
  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/flutter/wind_send";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Quickly and securely sync clipboard, transfer files and directories between devices";
    homepage = "https://github.com/doraemonkeys/WindSend";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "WindSend";
  };
})
