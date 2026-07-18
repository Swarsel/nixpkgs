{
  lib,
  _experimental-update-script-combinators,
  cwtch,
  dart,
  fetchgit,
  flutter329,
  nix-update-script,
  runCommand,
  tor,
  yq-go,
}:

let
  version = "1.16.3";
  # This Gitea instance has archive downloads disabled, so: fetchgit
  src = fetchgit {
    url = "https://git.openprivacy.ca/cwtch.im/cwtch-ui";
    tag = "v${version}";
    hash = "sha256-w1bIT9EIwpmJ4fkOGKo6iI3HdkcYgrGlW0xeecpUn7g=";
  };
in
flutter329.buildFlutterApplication {
  inherit version src;
  pname = "cwtch-ui";

  postInstall = ''
    mkdir -p $out/share/applications
    substitute linux/cwtch.template.desktop "$out/share/applications/cwtch.desktop" \
      --replace-fail PREFIX "$out"
  '';

  extraWrapProgramArgs = "--prefix PATH : ${lib.makeBinPath [ tor ]}";

  flutterBuildFlags = [
    "--dart-define"
    "BUILD_VER=${version}"
    "--dart-define"
    "BUILD_DATE=1980-01-01-00:00"
  ];

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  # These things are added to LD_LIBRARY_PATH, but not PATH
  runtimeDependencies = [ cwtch ];

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
        (_experimental-update-script-combinators.copyAttrOutputToFile "cwtch-ui.pubspecSource" ./pubspec.lock.json)
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
    description = "Messaging app built on the cwtch decentralized, privacy-preserving, multi-party messaging protocol";
    homepage = "https://cwtch.im/";
    changelog = "https://docs.cwtch.im/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.gmacon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cwtch";
  };
}
