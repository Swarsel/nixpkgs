{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron_42,
  makeDesktopItem,
  nodejs_22,
  python3,
  xdg-utils,
}:

buildNpmPackage.override { nodejs = nodejs_22; } rec {
  pname = "webcord";
  version = "4.13.2";

  src = fetchFromGitHub {
    owner = "SpacingBat3";
    repo = "WebCord";
    tag = "v${version}";
    hash = "sha256-td04ayA1AVDy6WCPQH3Y8zmZ6VfObqzFvm+cD8WZum4=";
  };

  # remove husky commit hooks, errors and aren't needed for packaging
  postPatch = ''
    rm -rf .husky
  '';

  nativeBuildInputs = [
    copyDesktopItems
    python3
  ];

  npmDepsHash = "sha256-LLxDJOLLBnjHRHTH/q1o3szu+armmwx9ZIKYKHUO+Z0=";
  # npm install will error when electron tries to download its binary
  # we don't need it anyways since we wrap the program with our nixpkgs electron
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # override installPhase so we can copy the only folders that matter
  installPhase =
    let
      binPath = lib.makeBinPath [ xdg-utils ];
    in
    ''
      runHook preInstall

      # Remove dev deps that aren't necessary for running the app
      npm prune --omit=dev

      mkdir -p $out/lib/node_modules/webcord
      cp -r app node_modules sources package.json $out/lib/node_modules/webcord/

      install -Dm644 sources/assets/icons/app.png $out/share/icons/hicolor/256x256/apps/webcord.png

      # Add xdg-utils to path via suffix, per PR #181171
      makeWrapper '${lib.getExe electron_42}' $out/bin/webcord \
        --suffix PATH : "${binPath}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --add-flags $out/lib/node_modules/webcord/

      runHook postInstall
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "InstantMessaging"
      ];

      comment = meta.description;
      desktopName = "WebCord";
      exec = "webcord";
      icon = "webcord";
      name = "webcord";
    })
  ];

  makeCacheWritable = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Discord and SpaceBar electron-based client implemented without Discord API";
    homepage = "https://github.com/SpacingBat3/WebCord";
    changelog = "https://github.com/SpacingBat3/WebCord/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      huantian
      NotAShelf
    ];

    platforms = lib.platforms.linux;
    mainProgram = "webcord";
    downloadPage = "https://github.com/SpacingBat3/WebCord/releases";
  };
}
