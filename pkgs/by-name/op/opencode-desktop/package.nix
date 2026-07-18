{
  lib,
  stdenv,
  autoPatchelfHook,
  bun,
  copyDesktopItems,
  electron_41,
  makeBinaryWrapper,
  makeDesktopItem,
  models-dev,
  nodejs,
  opencode,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
  commandLineArgs ? "",
}:

let
  electron = electron_41;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (opencode)
    version
    src
    node_modules
    patches
    ;

  pname = "opencode-desktop";

  postPatch = ''
    # The auto-updater would try to download and run an upstream binary that
    # isn't patched for Nix. Disable it at source.
    substituteInPlace packages/desktop/src/main/constants.ts \
      --replace-fail 'app.isPackaged && CHANNEL !== "dev"' 'false'

    # Relax Bun version check to be a warning instead of an error
    substituteInPlace packages/script/src/index.ts \
      --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
                     'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bun
    nodejs # for patchShebangs node_modules
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    MODELS_DEV_API_JSON = "${models-dev}/dist/_api.json";
    OPENCODE_CHANNEL = "prod";
    OPENCODE_DISABLE_MODELS_FETCH = true;
  };

  preBuild = lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    # Patch electron-builder to skip code signing on macOS.
    # The nix sandbox on public Darwin builders cannot spawn
    # `security find-identity` — trying gives spawn EPERM.
    # We patch the compiled JS to make getValidIdentities a no-op.
    for f in $(find node_modules -path "*/app-builder-lib/out/codeSign/macCodeSign.js" -type f 2>/dev/null); do
      substituteInPlace "$f" \
        --replace-fail "async function getValidIdentities" \
        "async function getValidIdentities() { return []; }; async function getValidIdentities_DISABLED"
    done
  '';

  buildPhase = ''
    runHook preBuild

    # Build the opencode node bundle (needed by the desktop sidecar)
    cd packages/opencode
    bun --bun ./script/build-node.ts --skip-install
    cd ../..

    # Prepare desktop app
    cd packages/desktop

    # Copy prod icons
    cp -R icons/prod resources/icons

    # Build with electron-vite
    node_modules/.bin/electron-vite build

    # Package with electron-builder (unpacked directory mode)
    cp -r "${electron.dist}" $HOME/.electron-dist
    chmod -R u+w $HOME/.electron-dist

    node_modules/.bin/electron-builder --dir \
      --config=electron-builder.config.ts \
      --config.electronDist="$HOME/.electron-dist" \
      --config.electronVersion=${electron.version} \
      --config.asarUnpack='**/*.node' \
      ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "--config.mac.identity=null"}

    cd ../..

    runHook postBuild
  '';

  installPhase =
    let
      appDir = if stdenvNoCC.hostPlatform.isAarch64 then "linux-arm64-unpacked" else "linux-unpacked";
    in
    lib.concatLines [
      ''
        runHook preInstall
      ''
      (lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
        mkdir -p $out/Applications $out/bin
        mv packages/desktop/dist/mac-*/OpenCode.app "$out/Applications/OpenCode.app"
        ln -s "$out/Applications/OpenCode.app/Contents/MacOS/OpenCode" $out/bin/opencode-desktop
      '')
      (lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
        mkdir -p $out/opt/opencode-desktop
        appDir="packages/desktop/dist/${appDir}"
        [ -d "$appDir" ] || { echo "no electron-builder output dir found: $appDir"; exit 1; }
        cp -r "$appDir/resources" $out/opt/opencode-desktop/

        for size in 32 64 128; do
          install -Dm644 \
            packages/desktop/resources/icons/''${size}x''${size}.png \
            $out/share/icons/hicolor/''${size}x''${size}/apps/opencode-desktop.png
        done
        for size in 30 44 71 89 107 142 150 284 310; do
          install -Dm644 \
            packages/desktop/resources/icons/Square''${size}x''${size}Logo.png \
            $out/share/icons/hicolor/''${size}x''${size}/apps/opencode-desktop.png
        done

        makeWrapper ${lib.getExe electron} $out/bin/opencode-desktop \
          --inherit-argv0 \
          --set ELECTRON_FORCE_IS_PACKAGED 1 \
          --add-flags $out/opt/opencode-desktop/resources/app.asar \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
          --add-flags ${lib.escapeShellArg commandLineArgs}
      '')
      ''
        runHook postInstall
      ''
    ];

  # The musl prebuilts ship libc.musl-*.so.1 SONAMEs that autoPatchelfHook can't
  # resolve on glibc systems. They aren't loaded at runtime on the host libc anyway.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  desktopItems = lib.optional stdenvNoCC.hostPlatform.isLinux (makeDesktopItem {
    categories = [ "Development" ];
    desktopName = "OpenCode";
    exec = "opencode-desktop %U";
    icon = "opencode-desktop";
    mimeTypes = [ "x-scheme-handler/opencode" ];
    name = "ai.opencode.desktop";
    startupWMClass = "ai.opencode.desktop";
  });

  meta = {
    inherit (opencode.meta) changelog platforms;
    description = "AI coding agent desktop client";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    mainProgram = "opencode-desktop";
  };
})
