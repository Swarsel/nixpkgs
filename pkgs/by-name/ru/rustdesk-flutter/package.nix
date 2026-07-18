{
  lib,
  fetchFromGitHub,
  addDriverRunpath,
  callPackage,
  cargo,
  cargo-expand,
  clangStdenv,
  copyDesktopItems,
  ffmpeg_7,
  flutter329,
  fuse3,
  gst_all_1,
  libaom,
  libayatana-appindicator,
  libopus,
  libpulseaudio,
  libva,
  libvdpau,
  libvpx,
  libxkbcommon,
  libxtst,
  libyuv,
  makeDesktopItem,
  openssl,
  pam,
  perl,
  pipewire,
  rustPlatform,
  rustc,
  rustfmt,
  xdg-user-dirs,
  xdotool,
  yq,
}:
let
  flutterRustBridge = rustPlatform.buildRustPackage rec {
    pname = "flutter_rust_bridge_codegen";
    version = "1.80.1"; # https://github.com/rustdesk/rustdesk/blob/1.4.4/.github/workflows/bridge.yml#L10

    src = fetchFromGitHub {
      owner = "fzyzcjy";
      repo = "flutter_rust_bridge";
      rev = "v${version}";
      hash = "sha256-SbwqWapJbt6+RoqRKi+wkSH1D+Wz7JmnVbfcfKkjt8Q=";
    };

    patches = [
      ./update-flutter-dev-path.patch
    ];

    cargoHash = "sha256-4khuq/DK4sP98AMHyr/lEo1OJdqLujOIi8IgbKBY60Y=";
    doCheck = false;

    cargoBuildFlags = [
      "--package"
      "flutter_rust_bridge_codegen"
    ];
  };

  ffigen = callPackage ./ffigen {
    flutter = flutter329;
  };

  sharedLibraryExt = rustc.stdenv.hostPlatform.extensions.sharedLibrary;

in
flutter329.buildFlutterApplication rec {
  pname = "rustdesk";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk";
    tag = version;
    hash = "sha256-FRtYafsIKHnGPV8NaiaHxIHkon8/T2P83uq9taUD1Xc=";
    fetchSubmodules = true;
  };

  patches = [
    ./make-build-reproducible.patch
  ];

  postPatch = ''
    cd flutter
    if [ $cargoDepsCopy ]; then # That will be inherited to buildDartPackage and it doesn't have cargoDepsCopy
      substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
        --replace-fail "libayatana-appindicator3.so.1" "${lib.getLib libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
      # Disable static linking of ffmpeg since https://github.com/21pages/hwcodec/commit/1873c34e3da070a462540f61c0b782b7ab15dc84
      sed -i 's/static=//g' $cargoDepsCopy/*/hwcodec-*/build.rs
      sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-1.1.0/src/sys/libwebm/mkvparser/mkvparser.cc
      sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-sys-1.0.4/libwebm/mkvparser/mkvparser.cc
    fi

    substituteInPlace ../Cargo.toml --replace-fail ", \"staticlib\", \"rlib\"" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    # flutter_rust_bridge_codegen
    cargo
    copyDesktopItems
    rustfmt
    # Rust
    rustPlatform.cargoSetupHook
    rustPlatform.cargoBuildHook
    cargo-expand
    rustPlatform.bindgenHook
    ffigen
    yq
    perl
  ];

  buildInputs = [
    ffmpeg_7
    fuse3
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libxtst
    libaom
    libopus
    libpulseaudio
    libva
    libvdpau
    libvpx
    pipewire
    libxkbcommon
    libyuv
    pam
    xdotool
    openssl
  ];

  env.OPENSSL_NO_VENDOR = true;
  env.VCPKG_ROOT = "/homeless-shelter"; # idk man, makes the build go since https://github.com/21pages/hwcodec/commit/1873c34e3da070a462540f61c0b782b7ab15dc84

  preBuild = ''
    # Build the Flutter/Rust bridge bindings
    cat <<EOF > bridge.yml
    rust_input:
      - "../src/flutter_ffi.rs"
    dart_output:
      - "./lib/generated_bridge.dart"
    llvm_path:
      - "${lib.getLib clangStdenv.cc.cc}"
    dart_format_line_length: 80
    llvm_compiler_opts: "-I ${lib.getLib clangStdenv.cc.cc}/lib/clang/${lib.versions.major clangStdenv.cc.version}/include -I ${clangStdenv.cc.libc_dev}/include"
    EOF
    runHook prepareBuildRunner
    RUST_LOG=info ${flutterRustBridge}/bin/flutter_rust_bridge_codegen bridge.yml

    # Build the Rust shared library
    cd ..
    preBuild=() # prevent loops
    cargoBuildHook
    mv ./target/*/release/liblibrustdesk${sharedLibraryExt} ./target/release/liblibrustdesk${sharedLibraryExt}
    cd flutter
  '';

  postInstall = ''
    mkdir -p $out/share/polkit-1/actions $out/share/icons/hicolor/{256x256,scalable}/apps
    cp ../res/128x128@2x.png $out/share/icons/hicolor/256x256/apps/rustdesk.png
    cp ../res/scalable.svg $out/share/icons/hicolor/scalable/apps/rustdesk.svg
  '';

  cargoBuildFeatures = [
    "flutter"
    "hwcodec"
    "linux-pkg-config"
  ];

  cargoBuildFlags = "--lib";
  cargoBuildType = "release";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      patches
      ;

    hash = "sha256-mEtTo1ony5w/dzJcHieG9WywHirBoQ/C0WpiAr7pUVc=";
  };

  # Configure the Rust build
  cargoRoot = "..";

  desktopItems = [
    (makeDesktopItem {
      actions.new-window = {
        exec = "rustdesk %u";
        name = "Open a New Window";
      };

      categories = [
        "Network"
        "RemoteAccess"
        "GTK"
      ];

      comment = "Remote Desktop";
      desktopName = "RustDesk";
      exec = "rustdesk %u";
      genericName = "Remote Desktop";
      icon = "rustdesk";
      keywords = [ "internet" ];
      name = "rustdesk";
      startupNotify = true;
      terminal = false;
      type = "Application";
    })
    (makeDesktopItem {
      desktopName = "RustDeskURL Scheme Handler";
      exec = "rustdesk %u";
      icon = "rustdesk";
      mimeTypes = [ "x-scheme-handler/rustdesk" ];
      name = "rustdesk-link";
      noDisplay = true;
      startupNotify = false;
      terminal = false;
      tryExec = "rustdesk";
      type = "Application";
    })
  ];

  dontCargoBuild = true;

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : ${addDriverRunpath.driverLink}/lib \
    --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}
  '';

  gitHashes = lib.importJSON ./git-hashes.json;

  prePatch = ''
    chmod -R +w ..
    cd ..
  '';

  prepareBuildRunner = ''
    cp ${./build-runner.sh} build_runner
    substituteInPlace build_runner \
      --replace-fail "@bash@" "$SHELL"
    chmod +x build_runner
    export PATH=$PATH:$PWD
  '';

  # curl https://raw.githubusercontent.com/rustdesk/rustdesk/1.4.1/flutter/pubspec.lock | yq > pubspec.lock.json
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  # Configure the Flutter/Dart build
  sourceRoot = "${src.name}/flutter";

  meta = {
    description = "Virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative";
    homepage = "https://rustdesk.com";
    changelog = "https://github.com/rustdesk/rustdesk/releases/${version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];

    platforms = lib.platforms.linux; # should work on darwin as well but I have no machine to test with
    mainProgram = "rustdesk";
  };
}
