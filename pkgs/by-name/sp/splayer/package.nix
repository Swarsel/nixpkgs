{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  copyDesktopItems,
  electron_41,
  fetchPnpmDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  python3,
  removeReferencesTo,
  rustPlatform,
  rustc,
}:
let
  electron = electron_41;
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "splayer";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "SPlayer-Dev";
    repo = "SPlayer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7oLFJqZ1Apq2GK5G3r10I+c3liSweDD2ZPhjpq0f+bM=";
    fetchSubmodules = false;
  };

  # When pnpm >= 10.29.3 and electron-builder < 26.8.2, it causes the package to fail at runtime; this patch will be removed once the upstream releases a version that includes the new version of electron-builder.
  patches = [ ./electron-builder-26.8.2.patch ];

  postPatch = ''
    # Workaround for https://github.com/electron/electron/issues/31121
    substituteInPlace electron/main/utils/native-loader.ts \
      --replace-fail 'process.resourcesPath' "'$out/share/splayer/resources'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    rustPlatform.cargoSetupHook
    cargo
    rustc
    python3
    makeWrapper
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postConfigure = ''
    cp .env.example .env
  '';

  buildPhase = ''
    runHook preBuild

    # After the pnpm configure, we need to build the binaries of all instances
    # of better-sqlite3. It has a native part that it wants to build using a
    # script which is disallowed.
    # What's more, we need to use headers from electron to avoid ABI mismatches.
    for f in $(find . -path '*/node_modules/better-sqlite3' -type d); do
      (cd "$f" && (
      npm run build-release --offline --nodedir="${electron.headers}"
      rm -rf build/Release/{.deps,obj,obj.target,test_extension.node}
      find build -type f -exec \
        ${lib.getExe removeReferencesTo} \
        -t "${electron.headers}" {} \;
      ))
    done

    pnpm build

    npm exec electron-builder -- \
        --dir \
        --config electron-builder.config.ts \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/splayer"
    cp -Pr --no-preserve=ownership dist/*-unpacked/{locales,resources{,.pak}} $out/share/splayer

    _icon_sizes=(16x16 32x32 96x96 192x192 256x256 512x512)
    for _icons in "''${_icon_sizes[@]}";do
      install -D public/icons/favicon-$_icons.png $out/share/icons/hicolor/$_icons/apps/splayer.png
    done

    makeWrapper '${lib.getExe electron}' "$out/bin/splayer" \
      --add-flags $out/share/splayer/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    hash = "sha256-dv8WqT6ei0dMwXcTQmUVHO9u1nGZ8iGhP2S8DpL+Hxk=";
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
        "Music"
      ];

      comment = "A minimalist music player";
      desktopName = "SPlayer";
      exec = "splayer %U";
      extraConfig.X-KDE-Protocols = "orpheus";
      icon = "splayer";
      mimeTypes = [ "x-scheme-handler/orpheus" ];
      name = "splayer";
      startupWMClass = "SPlayer";
      terminal = false;
      type = "Application";
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-HCSuCtJXaRMLCCZIKQ4ElDkrlYXFUIsHfK1H3pUSQX4=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Simple Netease Cloud Music player";
    homepage = "https://github.com/SPlayer-Dev/SPlayer";
    changelog = "https://github.com/SPlayer-Dev/SPlayer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # public/wasm/ffmpeg.wasm
      # source: https://github.com/apoint123/ffmpeg-audio-player
      # native/ferrous-opencc-wasm/pkg/ferrous_opencc_wasm_bg.wasm
      # source: native/ferrous-opencc-wasm
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
    mainProgram = "splayer";
  };
})
