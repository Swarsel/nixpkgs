{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  copyDesktopItems,
  flutter341,
  libayatana-appindicator,
  makeDesktopItem,
  nix-update-script,
  runCommand,
  yq-go,
}:

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "alisthelper";
  version = "0.2.0-unstable-2026-03-13";

  src = fetchFromGitHub {
    owner = "Xmarmalade";
    repo = "alisthelper";
    rev = "6d7e1acb86a5c67bcf86d99bc6034f130b1d04c2";
    hash = "sha256-EIE90R4lCnCLAi6D0YFdntB/tIhqKnoVhbqzk/4bj/k=";
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [ libayatana-appindicator ];

  preBuild = ''
    packageRun slang
    packageRun build_runner build --delete-conflicting-outputs
  '';

  postInstall = ''
    install -D assets/alisthelper.png $out/share/icons/alisthelper.png
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Alist Helper";
      exec = "alisthelper";
      icon = "alisthelper";
      name = "alisthelper";
    })
  ];

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
      (nix-update-script { extraArgs = [ "--version=branch" ]; })
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "alisthelper.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
    ];
  };

  meta = {
    description = "Designed to simplify the use of the desktop version of alist/openlist";
    homepage = "https://github.com/Xmarmalade/alisthelper";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "alisthelper";
  };
})
