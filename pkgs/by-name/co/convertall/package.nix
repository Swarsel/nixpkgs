{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  flutter341,
  nix-update-script,
  runCommand,
  yq-go,
}:

flutter341.buildFlutterApplication rec {
  pname = "convertall";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "doug-101";
    repo = "ConvertAll";
    tag = "v${version}";
    hash = "sha256-f9HfLfxY2G/3rZoWJ1xLeGmkdFiIyUFkr65Jf8QMqjY=";
  };

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
        (_experimental-update-script-combinators.copyAttrOutputToFile "convertall.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
    ];
  };

  meta = {
    description = "Graphical unit converter";
    homepage = "https://convertall.bellz.org";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Luflosi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "convertall";
  };
}
