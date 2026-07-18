{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildDartApplication,
  nix-update-script,
  runCommand,
  yq-go,
}:

let
  version = "4.1.2";

  src = fetchFromGitHub {
    owner = "leoafarias";
    repo = "fvm";
    tag = version;
    hash = "sha256-Kyxyt2UsrQ6Bc6EuYJjpEFdYwcus2/bcVrWsd/gs3Ok=";
  };
in
buildDartApplication {
  inherit version src;
  pname = "fvm";
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
        (_experimental-update-script-combinators.copyAttrOutputToFile "fvm.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
    ];
  };

  meta = {
    description = "Simple CLI to manage Flutter SDK versions";
    homepage = "https://github.com/leoafarias/fvm";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "fvm";
  };
}
