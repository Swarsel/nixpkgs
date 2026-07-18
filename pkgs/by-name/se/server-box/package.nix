{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  autoPatchelfHook,
  copyDesktopItems,
  dart,
  flutter344,
  makeDesktopItem,
  nix-update-script,
  runCommand,
  yq-go,
}:

let
  version = "1.0.1450";

  src = fetchFromGitHub {
    owner = "lollipopkit";
    repo = "flutter_server_box";
    tag = "v${version}";
    hash = "sha256-jgbuEgUxsN1ijH++NjXr3eZeTPUQbB/9axCMM/FWp54=";
    fetchSubmodules = true;
  };
in
flutter344.buildFlutterApplication {
  inherit version src;
  pname = "server-box";

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
  ];

  # https://github.com/juliansteenbakker/flutter_secure_storage/issues/965
  env.CXXFLAGS = toString [ "-Wno-deprecated-literal-operator" ];

  postInstall = ''
    install -D --mode=0644 assets/app_icon.png $out/share/icons/hicolor/512x512/apps/server-box.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      desktopName = "ServerBox";
      exec = "ServerBox";
      genericName = "ServerBox";
      icon = "server-box";

      keywords = [
        "server"
        "ssh"
        "sftp"
        "system"
      ];

      name = "server-box";
    })
  ];

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit src;
          nativeBuildInputs = [ yq-go ];
        }
        ''
          yq eval --output-format=json --prettyPrint $src/pubspec.lock > "$out"
        '';

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "server-box.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
      {
        command = [
          dart.fetchGitHashesScript
          "--input"
          ./pubspec.lock.json
          "--output"
          ./git-hashes.json
        ];

        supportedFeatures = [ ];
      }
    ];
  };

  meta = {
    description = "Server status & toolbox";
    homepage = "https://serverbox.lpkt.cn";
    changelog = "https://github.com/lollipopkit/flutter_server_box/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "ServerBox";
    downloadPage = "https://serverbox.lpkt.cn/installation";
  };
}
