{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  flutter341,
  makeDesktopItem,
  mpv-unwrapped,
  rustPlatform,
  webkitgtk_4_1,
  writeText,
}:

let
  pname = "mangayomi";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "kodjodevf";
    repo = "mangayomi";
    tag = "v${version}";
    hash = "sha256-p2PjylbwOSCtJlPhT7sf1VOZfJx6y0CkNY6xIo2ij5I=";
  };

  metaCommon = {
    changelog = "https://github.com/kodjodevf/mangayomi/releases/tag/v${version}";
    description = "Reading manga, novels, and watching animes";
    homepage = "https://github.com/kodjodevf/mangayomi";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

  rustDep = rustPlatform.buildRustPackage {
    inherit pname version src;
    cargoHash = "sha256-lKEkTHLTX6RdTxC8bU3GQm0RD2RBy4rDHzBHIiks4eg=";
    sourceRoot = "${src.name}/rust";
    passthru.libraryPath = "lib/librust_lib_mangayomi.so";
    meta = metaCommon;
  };
in
flutter341.buildFlutterApplication {
  inherit pname version src;
  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    alsa-lib
    mpv-unwrapped
    webkitgtk_4_1
  ];

  postInstall = ''
    install -Dm644 assets/app_icons/icon-red.png $out/share/icons/mangayomi.png
  '';

  customSourceBuilders = {
    flutter_discord_rpc_fork =
      { src, version, ... }:
      let
        flutter_discord_rpc_fork-rs = rustPlatform.buildRustPackage {
          inherit version src;
          pname = "flutter_discord_rpc_fork-rs";
          cargoHash = "sha256-oJOM/Tb4QrezdtU8YTyr57JZp5FkDewgwXrBqwp6cp8=";
          buildAndTestSubdir = "rust";
          passthru.libraryPath = "lib/libflutter_discord_rpc_fork.so";
        };
      in
      stdenv.mkDerivation {
        inherit version src;
        inherit (src) passthru;
        pname = "flutter_discord_rpc_fork";

        postPatch =
          let
            fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
              function(apply_cargokit target manifest_dir lib_name any_symbol_name)
                set("''${target}_cargokit_lib" ${flutter_discord_rpc_fork-rs}/${flutter_discord_rpc_fork-rs.passthru.libraryPath} PARENT_SCOPE)
              endfunction()
            '';
          in
          ''
            cp ${fakeCargokitCmake} cargokit/cmake/cargokit.cmake
          '';

        installPhase = ''
          runHook preInstall

          cp -r . "$out"

          runHook postInstall
        '';
      };

    rust_lib_mangayomi =
      { src, version, ... }:
      stdenv.mkDerivation {
        inherit version src;
        inherit (src) passthru;
        pname = "rust_lib_mangayomi";

        postPatch =
          let
            fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
              function(apply_cargokit target manifest_dir lib_name any_symbol_name)
                set("''${target}_cargokit_lib" ${rustDep}/${rustDep.passthru.libraryPath} PARENT_SCOPE)
              endfunction()
            '';
          in
          ''
            cp ${fakeCargokitCmake} rust_builder/cargokit/cmake/cargokit.cmake
          '';

        installPhase = ''
          runHook preInstall

          cp -r . "$out"

          runHook postInstall
        '';
      };
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
      ];

      desktopName = "Mangayomi";
      exec = "mangayomi";
      genericName = "Mangayomi";
      icon = "mangayomi";

      keywords = [
        "Manga"
        "Anime"
        "BitTorrent"
      ];

      name = "mangayomi";
    })
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/mangayomi/lib
  '';

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    inherit rustDep;
    updateScript = ./update.sh;
  };

  meta = metaCommon // {
    mainProgram = "mangayomi";
  };
}
