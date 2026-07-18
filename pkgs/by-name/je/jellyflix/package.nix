{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  flutter332,
  makeDesktopItem,
  mpv-unwrapped,
}:
flutter332.buildFlutterApplication rec {
  pname = "jellyflix";
  version = "1.4.886";

  src = fetchFromGitHub {
    owner = "jellyflix-app";
    repo = "jellyflix";
    tag = version;
    hash = "sha256-1kQIHUHDRKuJbqrYo40vjmcxSTPEi5uVUSi2MCKk6qA=";
  };

  postPatch = ''
    substituteInPlace lib/services/api_service.dart \
      --replace-fail "} on DioException catch (_) {
          return _.response!.statusCode ?? 400;" "} on DioException catch (e) {
          return e.response!.statusCode ?? 400;"

    substituteInPlace linux/CMakeLists.txt \
      --replace-fail "-Werror" ""
  '';

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
  ];

  postInstall = ''
    install -Dm644 $src/assets/icon/icon.png $out/share/icons/hicolor/scalable/apps/jellyflix.png
  '';

  customSourceBuilders = {
    volume_controller =
      { src, version, ... }:
      stdenv.mkDerivation {
        inherit version src;
        inherit (src) passthru;
        pname = "volume_controller";

        postPatch = ''
          substituteInPlace linux/CMakeLists.txt \
            --replace-fail '# ALSA dependency for volume control' 'find_package(PkgConfig REQUIRED)' \
            --replace-fail 'find_package(ALSA REQUIRED)' 'pkg_check_modules(ALSA REQUIRED alsa)'
        '';

        installPhase = ''
          runHook preInstall

          mkdir $out
          cp -r ./* $out/

          runHook postInstall
        '';
      };
  };

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Jellyflix";
      exec = "jellyflix";
      genericName = "Media Player";
      icon = "jellyflix";
      name = "jellyflix";
    })
  ];

  gitHashes =
    let
      media_kit-hash = "sha256-8dIiEeeBQOGST9kGHSp15Cdg377AQeBynbvWPAnGbJc=";
    in
    {
      filter_list = "sha256-cYnsujNMC6n9hZNHcbOevXWh54+jPeuHEUbdt1mDgP8=";
      media_kit = media_kit-hash;
      media_kit_libs_android_video = media_kit-hash;
      media_kit_libs_ios_video = media_kit-hash;
      media_kit_libs_macos_video = media_kit-hash;
      media_kit_libs_video = media_kit-hash;
      media_kit_libs_windows_video = media_kit-hash;
      media_kit_video = media_kit-hash;
      tentacle = "sha256-30a4Vn8wL0TdboSYPm1W+hRqXSsuID0gNOVnNe3KmPE=";
    };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  meta = {
    description = "Easy-to-use Jellyfin client for movies and shows";
    homepage = "https://github.com/jellyflix-app/jellyflix";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jvanbruegge ];
    platforms = lib.platforms.linux;
    mainProgram = "jellyflix";
  };
}
