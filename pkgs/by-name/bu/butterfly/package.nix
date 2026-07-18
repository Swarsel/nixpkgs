{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  dart,
  flutter341,
  gitUpdater,
  runCommand,
  yq-go,
}:

let
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "LinwoodDev";
    repo = "Butterfly";
    tag = "v${version}";
    hash = "sha256-XyBiEXL/hLKwsV/Lc5SFaeqHlJxGgwET0PIy2Bu8t4A=";
  };
in
flutter341.buildFlutterApplication {
  inherit version src;
  pname = "butterfly";

  postInstall = ''
    cp -r linux/debian/usr/share $out/share
  '';

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/app";

  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit src;
          nativeBuildInputs = [ yq-go ];
        }
        ''
          yq eval --output-format=json --prettyPrint $src/app/pubspec.lock > "$out"
        '';

    updateScript = _experimental-update-script-combinators.sequence [
      (
        (gitUpdater {
          ignoredVersions = ".*(rc|beta).*";
          rev-prefix = "v";
        })
        // {
          supportedFeatures = [ ];
        }
      )
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "butterfly.pubspecSource" ./pubspec.lock.json)
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
    description = "Note taking app where your ideas come first";
    homepage = "https://github.com/LinwoodDev/Butterfly";

    license = with lib.licenses; [
      agpl3Plus
      cc-by-sa-40
      asl20
    ];

    maintainers = [ ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "butterfly";
  };
}
