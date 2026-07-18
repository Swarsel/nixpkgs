{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cargo-tauri,
  dbus,
  fetchNpmDeps,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  gvfs,
  libGL,
  libappindicator,
  libheif,
  libjpeg,
  libpng,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  makeWrapper,
  nodejs_24,
  npmHooks,
  onnxruntime,
  openssl,
  pango,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  webkitgtk_4_1,
  wrapGAppsHook4,
  writableTmpDirAsHomeHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rapidraw";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "CyberTimon";
    repo = "RapidRAW";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LbAEQwZeFeiKV6lVt8vh+mZpqlJ02RSHs0rZEMeMRc4=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    wrapGAppsHook4
    nodejs_24
    npmHooks.npmConfigHook
    cargo-tauri.hook
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    nodejs_24
    glib-networking
    openssl
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    libx11
    libxi
    libxcursor
    libxext
    libxrandr
    libxrender
    libxcb
    libxfixes
    libxkbcommon
    vulkan-loader
    libjpeg
    libpng
    zlib
    libGL
    dbus
    gvfs
    libheif
    onnxruntime
    wrapGAppsHook4
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    libappindicator
  ];

  cargoHash = "sha256-vx4+5aMxML5Cp1s7HKHSOYS4d4HaAGO2l6jMZuFPUsQ=";

  env = {
    ORT_STRATEGY = "system";
  };

  # Set HOME for npm to avoid permission issues and add node_modules to path
  preBuild = ''
    export PATH="$PWD/node_modules/.bin:$PATH"

    # Configure Tauri to use lowercase binary name
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '  "identifier": "io.github.CyberTimon.RapidRAW",' '  "identifier": "io.github.CyberTimon.RapidRAW", "mainBinaryName": "rapidraw",'

    # Disable downloading of ONNX runtime library this is correctly linked during postInstall
    substituteInPlace src-tauri/build.rs \
      --replace-fail 'if !is_valid' 'if false'
  '';

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      # Patch the .desktop file to set the Categories field
      sed -i '/^Categories=/c\Categories=Graphics;Photography' "$out/share/applications/RapidRAW.desktop"

      # Ensure the resources directory exists before linking
      mkdir -p $out/lib/RapidRAW/resources

      # link the .so file
      ln -sf ${onnxruntime}/lib/libonnxruntime.so $out/lib/RapidRAW/resources/libonnxruntime.so
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # The app also dlopen()s libonnxruntime.dylib at a hardcoded path inside the bundle
      mkdir -p "$out/Applications/RapidRAW.app/Contents/Resources/resources"
      ln -sf ${onnxruntime}/lib/libonnxruntime.dylib "$out/Applications/RapidRAW.app/Contents/Resources/resources/libonnxruntime.dylib"
    '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapGApp $out/bin/rapidraw \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs} \
        --set ORT_STRATEGY "system"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      wrapGApp "$out/Applications/RapidRAW.app/Contents/MacOS/rapidraw" \
        --set ORT_STRATEGY "system"
    '';

  buildAndTestSubdir = "src-tauri";
  cargoRoot = "src-tauri";
  dontWrapGApps = true;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-JtkzeCt21KIEshvoCHWo1QoxUgvVJN1loJrUHgvV4qE=";
  };

  meta = {
    description = "Blazingly-fast, non-destructive, and GPU-accelerated RAW image editor built with performance in mind";
    homepage = "https://github.com/CyberTimon/RapidRAW";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      philipdb
      taciturnaxolotl
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rapidraw";
  };
})
