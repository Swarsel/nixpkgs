{
  lib,
  fetchFromGitHub,
  flutter335,
  libsecret,
  makeDesktopItem,
}:

flutter335.buildFlutterApplication rec {
  pname = "onyx";
  version = "2.0.12";

  src = fetchFromGitHub {
    owner = "onyx-lyon1";
    repo = "onyx";
    tag = "v${version}";
    hash = "sha256-WQH1qhu5UFB/RToraO/zEU6BjzwhNWrsk+U8ZIs1VLM=";
  };

  buildInputs = [
    libsecret
  ];

  postInstall = ''
    install -Dm644 assets/icon_transparent.png $out/share/icons/hicolor/512x512/apps/onyx.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Education"
        "Office"
      ];

      desktopName = "Onyx";
      exec = "Onyx";
      genericName = "App for Claude Bernard University";
      icon = "onyx";
      name = "onyx";
      startupWMClass = "Onyx";
    })
  ];

  gitHashes = {
    dart_mappable = "sha256-i4KJXxZCV5L+er1pOkknh3hmZ/y+HcBKly29hG3+lDc=";
    dart_mappable_builder = "sha256-i4KJXxZCV5L+er1pOkknh3hmZ/y+HcBKly29hG3+lDc=";
    drag_and_drop_lists = "sha256-moyKVIaqCCLeR5dvvd+DW7cpgPG4NCBp3+ohMEwT3FE=";
    geolocator_android = "sha256-qXk7Tg/e2oc8/0eGcTCJ4Po+wCzUqfqWZMaHXflgyrE=";
    json_theme = "sha256-OuJBQDqytLds6BB4/GS01A4H9OZYt4g4QsK7ugO3o+I=";
    workmanager = "sha256-a+IPLiWrRxKmWCJ9Bpv3WVH6JwTRiFPQdxSkeQEbfp4=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/apps/onyx";

  meta = {
    description = "App for Claude Bernard University";
    homepage = "https://onyx-lyon1.github.io/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ eymeric ];
    platforms = lib.platforms.linux;
    mainProgram = "Onyx";
  };
}
