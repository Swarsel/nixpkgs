{
  lib,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  flutter344,
  libappindicator,
  libplacebo,
  makeDesktopItem,
  mpv-unwrapped,
  webkitgtk_4_1,
}:

let
  srcInfo = lib.importJSON ./src-info.json;
  description = "Third-party Bilibili client developed in Flutter";
  version = "2.0.9.2";
in
flutter344.buildFlutterApplication {
  inherit version;
  pname = "piliplus";

  src = fetchFromGitHub {
    inherit (srcInfo) rev hash;
    owner = "bggRGjQaUbCoE";
    repo = "PiliPlus";
  };

  patches = [ ./disable-auto-update.patch ];
  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
    libplacebo
    libappindicator
    webkitgtk_4_1
  ];

  # See lib/scripts/build.sh.
  preBuild = ''
    cat <<EOL > lib/build_config.dart
    class BuildConfig {
      static const int versionCode = ${toString srcInfo.revCount};
      static const String versionName = '${version}';

      static const int buildTime = ${toString srcInfo.commitDate};
      static const String commitHash = '${srcInfo.rev}';
    }
    EOL
  '';

  postInstall = ''
    declare -A sizes=(
      [mdpi]=128
      [hdpi]=192
      [xhdpi]=256
      [xxhdpi]=384
      [xxxhdpi]=512
    )
    for var in "''${!sizes[@]}"; do
      width=''${sizes[$var]}
      install -Dm644 "android/app/src/main/res/drawable-$var/splash.png" \
        "$out/share/icons/hicolor/''${width}x$width/apps/piliplus.png"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Video"
        "AudioVideo"
      ];

      comment = description;
      desktopName = "PiliPlus";
      exec = "piliplus";
      icon = "piliplus";
      name = "piliplus";
    })
  ];

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  passthru.updateScript = ./update.rb;

  meta = {
    inherit description;
    homepage = "https://github.com/bggRGjQaUbCoE/PiliPlus";
    changelog = "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "piliplus";
  };
}
