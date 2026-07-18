{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  buildGoModule,
  copyDesktopItems,
  flutter335,
  imagemagick,
  keybinder3,
  libayatana-appindicator,
  makeDesktopItem,
}:

let
  pname = "flclash";
  version = "0.8.92";

  src = fetchFromGitHub {
    owner = "chen08209";
    repo = "FlClash";
    tag = "v${version}";
    hash = "sha256-bPz2QNwhlCZBmjU0ZpRTwNk0TKVTIHH4E6ZJ5+rtaTk=";
    fetchSubmodules = true;

    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
  };

  meta = {
    description = "Proxy client based on ClashMeta, simple and easy to use";
    homepage = "https://github.com/chen08209/FlClash";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ VZstless ];
  };

  core = buildGoModule {
    inherit version src meta;
    pname = "core";
    vendorHash = "sha256-/p/Z5vIstuerR5jA0vXXLURSoPqS7IDEIXCa/SFCrLc=";
    env.CGO_ENABLED = 0;

    buildPhase = ''
      runHook preBuild

      mkdir -p $out/bin
      go build -ldflags="-w -s" -tags=with_gvisor -o $out/bin/FlClashCore

      runHook postBuild
    '';

    modRoot = "core";
  };
in
flutter335.buildFlutterApplication {
  inherit pname version src;

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    imagemagick
  ];

  buildInputs = [
    keybinder3
    libayatana-appindicator
  ];

  preBuild = ''
    mkdir -p libclash/linux
    cp ${core}/bin/FlClashCore libclash/linux/FlClashCore
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/512x512/apps
    magick assets/images/icon.png -resize 512x512 $out/share/icons/hicolor/512x512/apps/flclash.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      desktopName = "FlClash";
      exec = "FlClash %U";
      genericName = "FlClash";
      icon = "flclash";

      keywords = [
        "FlClash"
        "Clash"
        "ClashMeta"
        "Proxy"
      ];

      name = "flclash";
      startupWMClass = "com.follow.clash";
    })
  ];

  flutterBuildFlags = [ "--dart-define=APP_ENV=stable" ];
  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    inherit core;
    updateScript = ./update.sh;
  };

  meta = meta // {
    platforms = lib.platforms.linux;
    mainProgram = "FlClash";
  };
}
