{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  copyDesktopItems,
  dart,
  flutter341,
  makeDesktopItem,
  nix-update-script,
  runCommand,
  webkitgtk_4_1,
  yq-go,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "venera";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "venera-app";
    repo = "venera";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UgQej91SsqyZzJaN3kQDHqJI3686W451wBTeTACXrV8=";
  };

  nativeBuildInputs = [ copyDesktopItems ];
  buildInputs = [ webkitgtk_4_1 ];

  postInstall = ''
    install -D --mode=0644 debian/gui/venera.png $out/share/icons/venera.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
      ];

      desktopName = "Venera";
      exec = "venera";
      genericName = "Venera";
      icon = "venera";

      keywords = [
        "Flutter"
        "comic"
        "images"
      ];

      name = "venera";
    })
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/venera/lib
  '';

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit (finalAttrs) src;
          nativeBuildInputs = [ yq-go ];
        }
        ''
          yq eval --output-format=json --prettyPrint $src/pubspec.lock > "$out"
        '';

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "venera.pubspecSource" ./pubspec.lock.json)
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
    description = "Comic reader that support reading local and network comics";
    homepage = "https://github.com/venera-app/venera";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "venera";
  };
})
