{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  flutter335,
  libdisplay-info,
  libepoxy,
  libxpresent,
  libxscrnsaver,
  makeBinaryWrapper,
  makeDesktopItem,
  mpv-unwrapped,
  undmg,
  baseUrl ? null,
  targetFlutterPlatform ? "linux",
}:

let
  flutter = flutter335;
  sourceBuild = flutter.buildFlutterApplication (finalAttrs: {
    inherit targetFlutterPlatform;
    pname = "fladder";
    version = "0.10.3";

    src = fetchFromGitHub {
      owner = "DonutWare";
      repo = "Fladder";
      tag = "v${finalAttrs.version}";
      hash = "sha256-0eFHylRi2UVaKRG7K3tDZVscgoiL5xFrtFhZiJxj4Mk=";
    };

    nativeBuildInputs = lib.optionals (targetFlutterPlatform == "linux") [
      copyDesktopItems
    ];

    buildInputs = [
      alsa-lib
      libdisplay-info
      mpv-unwrapped
      libxpresent
      libxscrnsaver
    ]
    ++ lib.optionals (targetFlutterPlatform == "linux") [
      libepoxy
    ];

    postInstall =
      lib.optionalString (targetFlutterPlatform == "web") (
        ''
          sed -i 's;base href="/";base href="$out";' $out/index.html
        ''
        + lib.optionalString (baseUrl != null) ''
          echo '{"baseUrl": "${baseUrl}"}' > $out/assets/config/config.json
        ''
      )
      + lib.optionalString (targetFlutterPlatform == "linux") ''
        # Install SVG icon
        install -Dm644 icons/fladder_icon.svg \
          $out/share/icons/hicolor/scalable/apps/fladder.svg
      '';

    desktopItems = lib.optionals (targetFlutterPlatform == "linux") [
      (makeDesktopItem {
        categories = [
          "AudioVideo"
          "Video"
          "Player"
        ];

        comment = "Simple Jellyfin Frontend built on top of Flutter";
        desktopName = "Fladder";
        exec = "Fladder";
        genericName = "Jellyfin Client";
        icon = "fladder";
        name = "fladder";
      })
    ];

    gitHashes = lib.importJSON ./git-hashes.json;
    pubspecLock = lib.importJSON ./pubspec.lock.json;
    passthru.updateScript = ./update.sh;

    meta = {
      description = "Simple Jellyfin Frontend built on top of Flutter";
      homepage = "https://github.com/DonutWare/Fladder";
      license = lib.licenses.gpl3Only;

      maintainers = with lib.maintainers; [
        ratcornu
        schembriaiden
      ];

      mainProgram = "Fladder";
      downloadPage = "https://github.com/DonutWare/Fladder/releases";
    };
  });

  darwin = stdenv.mkDerivation {
    inherit (sourceBuild) version;
    pname = sourceBuild.pname;

    src = fetchurl {
      url = "https://github.com/DonutWare/Fladder/releases/download/v${sourceBuild.version}/Fladder-macOS-${sourceBuild.version}.dmg";
      hash = "sha256-Vnz0jtmDptcrehE7DrgyTzFJJopirsLaO+lu1V/Xd+o=";
    };

    nativeBuildInputs = [
      undmg
      makeBinaryWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r Fladder.app $out/Applications
      makeBinaryWrapper $out/Applications/Fladder.app/Contents/MacOS/Fladder $out/bin/Fladder

      runHook postInstall
    '';

    sourceRoot = ".";

    meta = sourceBuild.meta // {
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = lib.platforms.darwin;
    };
  };
in
if stdenv.hostPlatform.isDarwin then darwin else sourceBuild
