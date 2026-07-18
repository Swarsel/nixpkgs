{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  copyDesktopItems,
  corrosion,
  dbus,
  flutter338,
  jdk,
  makeDesktopItem,
  pkg-config,
  runCommand,
  rustPlatform,
  rustc,
  udev,
  writeText,
  zlib,
}:

let
  zlib-root = runCommand "zlib-root" { } ''
    mkdir $out
    ln -s ${zlib.dev}/include $out/include
    ln -s ${zlib}/lib $out/lib
  '';

  pname = "intiface-central";

  version = "3.0.4+40";

  src = fetchFromGitHub {
    owner = "intiface";
    repo = "intiface-central";
    tag = "v${version}";
    hash = "sha256-RMllaThwCp2mRl0ecMtj3z6DC4uhdLqYNPI8lZChmhI=";
  };

  rustDep = rustPlatform.buildRustPackage {
    inherit pname version src;
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      dbus
      udev
    ];

    cargoHash = "sha256-2KmwfvSDIaLvGda/EofUxGPRevv+/UQOUdSPRF2LEJw=";

    preBuild = ''
      chmod +w ../..
      ln -s ${buttplug} ../../buttplug
    '';

    sourceRoot = "${src.name}/rust";
    passthru.libraryPath = "lib/librust_lib_intiface_central.so";
  };

  buttplug_dart = fetchFromGitHub {
    hash = "sha256-nm9TdEL9+80hCbaPnpAJTQ0w1t40vWYcxyilQTwvEBU=";
    owner = "buttplugio";
    repo = "buttplug_dart";
    tag = "v1.0.0";
  };

  buttplug = fetchFromGitHub {
    hash = "sha256-4tzGZEsqfCnz/ZX6qNx/Hku6yDK0g6gyep6p6WZGoQk=";
    owner = "buttplugio";
    repo = "buttplug";
    tag = "intiface_engine_4.0.2";
  };
in
flutter338.buildFlutterApplication {
  inherit pname version src;

  patches = [
    ./corrosion.patch
  ];

  nativeBuildInputs = [
    corrosion
    rustPlatform.cargoSetupHook
    cargo
    rustc
    copyDesktopItems
  ];

  buildInputs = [
    jdk
    udev
  ];

  env.ZLIB_ROOT = zlib-root;

  preConfigure = ''
    export CMAKE_PREFIX_PATH="${corrosion}:$CMAKE_PREFIX_PATH"
  '';

  preBuild = ''
    chmod +w ..
    ln -s ${buttplug_dart} ../buttplug_dart
    ln -s ${buttplug} ../buttplug
  '';

  postInstall = ''
    install -Dm644 $out/app/intiface-central/data/flutter_assets/assets/icons/intiface_central_icon.png $out/share/icons/hicolor/512x512/apps/intiface-central.png
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = rustDep.cargoHash;
    sourceRoot = "${src.name}/rust";
  };

  cargoRoot = "rust";

  customSourceBuilders = {
    rust_lib_intiface_central =
      { src, version, ... }:
      stdenv.mkDerivation {
        inherit version src;
        inherit (src) passthru;
        pname = "rust_lib_intiface_central";

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
      comment = "Intiface Central (Buttplug Frontend) Application for Desktop";
      desktopName = "Intiface Central";
      exec = "intiface_central";
      icon = "intiface-central";
      name = "intiface-central";
    })
  ];

  # without this, only the splash screen will be shown
  extraWrapProgramArgs = "--set FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR $out/app/intiface-central/lib";
  gitHashes.buttplug = "sha256-nm9TdEL9+80hCbaPnpAJTQ0w1t40vWYcxyilQTwvEBU=";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Intiface Central (Buttplug Frontend) Application for Desktop";
    homepage = "https://intiface.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ _999eagle ];
    platforms = lib.platforms.linux;
    mainProgram = "intiface_central";
  };
}
