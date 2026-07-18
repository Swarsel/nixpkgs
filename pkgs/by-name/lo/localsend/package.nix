{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  copyDesktopItems,
  fetchpatch,
  flutter329,
  libayatana-appindicator,
  makeBinaryWrapper,
  makeDesktopItem,
  nixosTests,
  undmg,
}:

let
  pname = "localsend";
  version = "1.17.0";

  linux = flutter329.buildFlutterApplication rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "localsend";
      repo = "localsend";
      tag = "v${version}";
      hash = "sha256-1xMzlIcGEJ58laSM48bCKMxzHQ36eUHD5Mac0O1dnXk=";
    };

    patches = [
      # Fix for https://github.com/localsend/localsend/security/advisories/GHSA-34v6-52hh-x4r4
      # See: https://github.com/NixOS/nixpkgs/issues/488755
      # Can be removed with new release > 1.17.0
      (fetchpatch {
        hash = "sha256-Fswir+TebCDPxHVBg8YM3ROx2uoLG92E3E15wnzHz+U=";
        url = "https://github.com/localsend/localsend/commit/8f3cec85aa29b2b13fed9b2f8e499e1ac9b0504c.patch";
      })
    ];

    postPatch = ''
      substituteInPlace lib/util/native/autostart_helper.dart \
        --replace-fail 'Exec=''${Platform.resolvedExecutable}' "Exec=localsend_app"
    '';

    nativeBuildInputs = [
      copyDesktopItems
    ];

    buildInputs = [ libayatana-appindicator ];

    postInstall = ''
      for s in 32 128 256 512; do
        d=$out/share/icons/hicolor/''${s}x''${s}/apps
        mkdir -p $d
        cp ./assets/img/logo-''${s}.png $d/localsend.png
      done
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [
          "GTK"
          "FileTransfer"
          "Utility"
        ];

        desktopName = "LocalSend";
        exec = "localsend_app %U";
        genericName = "An open source cross-platform alternative to AirDrop";
        icon = "localsend";

        keywords = [
          "Sharing"
          "LAN"
          "Files"
        ];

        name = "LocalSend";
        startupNotify = true;
        startupWMClass = "localsend_app";
      })
    ];

    extraWrapProgramArgs = ''
      --prefix LD_LIBRARY_PATH : $out/app/localsend/lib
    '';

    gitHashes = {
      pasteboard = "sha256-lJA5OWoAHfxORqWMglKzhsL1IFr9YcdAQP/NVOLYB4o=";
      permission_handler_windows = "sha256-+TP3neqlQRZnW6BxHaXr2EbmdITIx1Yo7AEn5iwAhwM=";
    };

    patchFlags = [ "-p2" ];
    pubspecLock = lib.importJSON ./pubspec.lock.json;
    sourceRoot = "${src.name}/app";

    passthru = {
      tests.localsend = nixosTests.localsend;
      updateScript = ./update.sh;
    };

    meta = metaCommon // {
      mainProgram = "localsend_app";
    };
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/localsend/localsend/releases/download/v${version}/LocalSend-${version}.dmg";
      hash = "sha256-/fGkLuE+uf3WrpTcWIOYHooJWZ51i94j9uZ3xPq1yTw=";
    };

    nativeBuildInputs = [
      undmg
      makeBinaryWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r LocalSend.app $out/Applications
      makeBinaryWrapper $out/Applications/LocalSend.app/Contents/MacOS/LocalSend $out/bin/localsend

      runHook postInstall
    '';

    sourceRoot = ".";

    meta = metaCommon // {
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

      platforms = [
        "aarch64-darwin"
      ];

      mainProgram = "localsend";
    };
  };

  metaCommon = {
    description = "Open source cross-platform alternative to AirDrop";
    donationPage = "https://localsend.org/donate";
    homepage = "https://localsend.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sikmir
      linsui
      pandapip1
    ];
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
