{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  electron_42,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  node-gyp,
  nodejs,
  pkg-config,
  python3Packages,
  vips,
  xvfb-run,
  yarn-berry_4,
}:
let
  yarn-berry = yarn-berry_4;
  electron = electron_42;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rocketchat-desktop";
  version = "4.15.2";

  src = fetchFromGitHub {
    owner = "RocketChat";
    repo = "Rocket.Chat.Electron";
    tag = finalAttrs.version;
    hash = "sha256-wme3RKGaHuoOf7yyXH3PZ/0xL73LqS9rPqL8IcxyAkA=";
  };

  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/RocketChat/Rocket.Chat.Electron/blob/master/package.json#L182
    ./yarn-4.14-support.patch
  ];

  postPatch = ''
    # Avoid downloading a changing file during the `rollup` build
    substituteInPlace rollup.config.mjs \
      --replace-fail 'downloadSupportedVersions(),' ""
  '';

  nativeBuildInputs = [
    yarn-berry.yarnBerryConfigHook
    yarn-berry
    nodejs # needed for rollup
    # needed for vips compilation for the JS sharp dependency
    pkg-config
    node-gyp
    python3Packages.python
    python3Packages.distutils
    # install phase helpers
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    vips
  ];

  env = {
    ELECTRON_OVERRIDE_DIST_PATH = electron.dist;
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    NODE_ENV = "production";
    PUPPETEER_SKIP_DOWNLOAD = "1";
  };

  buildPhase = ''
    runHook preBuild

    yarn build

    # electronDist needs to be writable
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    yarn electron-builder \
        --config electron-builder.json \
        --dir \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = "yarn test";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications

    cp -a dist/*-unpacked/resources $out/share/rocketchat-desktop

    for icon in build/icons/*.png
    do
      install -Dm644 $icon $out/share/icons/hicolor/$(basename ''${icon%.png})/apps/rocketchat-desktop.png
    done

    makeWrapper '${lib.getExe electron}' $out/bin/rocketchat-desktop \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags $out/share/rocketchat-desktop/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];

      comment = "Official Desktop Client for Rocket.Chat";
      desktopName = "Rocket.Chat";
      exec = "rocketchat-desktop";
      genericName = "Rocket.Chat";
      icon = "rocketchat-desktop";
      mimeTypes = [ "x-scheme-handler/rocketchat" ];
      name = "rocketchat-desktop";
      startupWMClass = "Rocket.Chat";
      terminal = false;
      type = "Application";
    })
  ];

  # This might need to be updated between releases.
  # See https://nixos.org/manual/nixpkgs/stable/#javascript-yarnBerry-missing-hashes
  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes patches;
    hash = "sha256-XYfC5K7oXVjxP6Ndlc3qYb47Zh3GnwPx7c4+vBiA2AI=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official Desktop client for Rocket.Chat";
    homepage = "https://github.com/RocketChat/Rocket.Chat.Electron";
    changelog = "https://github.com/RocketChat/Rocket.Chat.Electron/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mynacol ];
    platforms = lib.platforms.linux;
    mainProgram = "rocketchat-desktop";
  };
})
