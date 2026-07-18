{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoPatchelfHook,
  cctools,
  copyDesktopItems,
  electron_40,
  fetchPnpmDeps,
  libevdev,
  libx11,
  libxfixes,
  libxi,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs-slim,
  pkg-config,
  pnpmConfigHook,
  pnpm_10_29_2,
  wayland,
  writableTmpDirAsHomeHook,
  commandLineArgs ? "",
}:

let
  electron = electron_40;
  pnpm = pnpm_10_29_2;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cherry-studio";
  version = "1.9.11";

  src = fetchFromGitHub {
    owner = "CherryHQ";
    repo = "cherry-studio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NbjFPHMh8LSqUv3wpXI/hBU9aJFe76l5UyoZ2XqX0hg=";
  };

  postPatch = ''
    substituteInPlace src/main/services/ConfigManager.ts \
      --replace-fail "ConfigKeys.AutoUpdate, true" "ConfigKeys.AutoUpdate, false" \
      --replace-fail "ConfigKeys.AutoUpdate, value" "ConfigKeys.AutoUpdate, false"
    substituteInPlace src/main/services/AppUpdater.ts \
      --replace-fail " = isActive" " = false"
    substituteInPlace src/renderer/src/hooks/useSettings.ts \
      --replace-fail "isAutoUpdate)" "false)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    nodejs-slim
    (nodejs-slim.python.withPackages (ps: with ps; [ setuptools ]))
    pnpm
    pnpmConfigHook
    makeWrapper
    writableTmpDirAsHomeHook
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools.libtool ]
  ++ lib.optionals stdenv.hostPlatform.isElf [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    alsa-lib
    libevdev
    libx11
    libxi
    libxtst
    libxfixes
    wayland
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isLinux "-I${lib.getDev libevdev}/include/libevdev-1.0";
  };

  buildPhase = ''
    runHook preBuild

    cp -r "${electron.dist}" $HOME/.electron-dist
    chmod -R u+w $HOME/.electron-dist

    node_modules/.bin/electron-vite build
    npm_config_nodedir=${electron.headers} npm_config_build_from_source=true node_modules/.bin/electron-builder --dir \
      --config=electron-builder.yml \
      --config.mac.identity=null \
      --config.electronDist="$HOME/.electron-dist" \
      --config.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv "dist/mac-${stdenv.hostPlatform.darwinArch}/Cherry Studio.app" "$out/Applications/Cherry Studio.app"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/opt/cherry-studio
    ${
      if stdenv.hostPlatform.isAarch64 then
        "cp -r dist/linux-arm64-unpacked/{resources,LICENSE*} $out/opt/cherry-studio"
      else
        "cp -r dist/linux-unpacked/{resources,LICENSE*} $out/opt/cherry-studio"
    }
    install -Dm644 build/icon.png $out/share/icons/cherry-studio.png
    makeWrapper ${lib.getExe electron} $out/bin/cherry-studio \
      --inherit-argv0 \
      --add-flags $out/opt/cherry-studio/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}
  ''
  + ''
    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-*.so.*"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "A powerful AI assistant for producer.";
      desktopName = "Cherry Studio";
      exec = "cherry-studio --no-sandbox %U";
      icon = "cherry-studio";
      mimeTypes = [ "x-scheme-handler/cherrystudio" ];
      name = "cherry-studio";
      startupWMClass = "CherryStudio";
      terminal = false;
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-9Vx4WzQjwNxPAkz+FjjqnMQxJviP4e0EhkQBN9Y+ujo=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Desktop client that supports for multiple LLM providers";
    homepage = "https://github.com/CherryHQ/cherry-studio";
    changelog = "https://github.com/CherryHQ/cherry-studio/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ agpl3Only ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "cherry-studio";
  };
})
