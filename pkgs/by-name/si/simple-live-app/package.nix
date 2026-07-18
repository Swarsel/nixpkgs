{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  copyDesktopItems,
  flutter332,
  makeDesktopItem,
  mpv,
}:

flutter332.buildFlutterApplication rec {
  pname = "simple-live-app";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "xiaoyaocz";
    repo = "dart_simple_live";
    tag = "v${version}";
    hash = "sha256-6kEty4QZZQW3Xzz4213ThC4FF+quMNE4oAuZ1limxFg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [ mpv ];

  postInstall = ''
    install -Dm644 assets/logo.png $out/share/icons/simple-live-app.png
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Simple-Live";
      exec = "simple_live_app";
      genericName = "Simple-Live";
      icon = "simple-live-app";
      keywords = [ "Simple Live" ];
      name = "simple-live-app";
    })
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/simple-live-app/lib
  '';

  gitHashes.ns_danmaku = "sha256-Hzp5QsdgBStaPVSHdHul7ZqOhZHQS9dbO+RpC4wMYqo=";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/simple_live_app";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Simply Watch Live";
    homepage = "https://github.com/xiaoyaocz/dart_simple_live";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "simple_live_app";
  };
}
