{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildNpmPackage,
  callPackage,
  copyDesktopItems,
  electron,
  fetchNpmDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs_22,
  steam-run-free,
}:

buildNpmPackage (finalAttrs: {
  pname = "bs-manager";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "Zagrios";
    repo = "bs-manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hx6ciEz772NYd9+7WjLqTzNNenWMoOq57IneqsDC1Qg=";
  };

  postPatch = ''
    # don't search for resources in electron's resource directory, but our own
    substituteInPlace src/main/services/utils.service.ts \
      --replace-fail "process.resourcesPath" "'$out/share/bs-manager/resources'"

    # replace vendored DepotDownloader with our own
    rm assets/scripts/DepotDownloader
    ln -s ${finalAttrs.passthru.depotdownloader}/bin/DepotDownloader assets/scripts/DepotDownloader
  '';

  nativeBuildInputs = [
    autoPatchelfHook # for some prebuilt node deps: query-process @resvg/resvg-js
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc
  ];

  npmDepsHash = "sha256-wmPZv1lqGr31wBGaeLw7LL6ZMzq/x8lkoy/iMxU+M80=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  preBuild = ''
    pushd release/app

    rm -r "$npm_config_cache"
    npmDeps="$extraNpmDeps" npmConfigHook
    npm run postinstall

    popd
  '';

  postBuild = ''
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      --config=electron-builder.config.js \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    for icon in build/icons/png/*.png; do
      install -Dm644 $icon $out/share/icons/hicolor/$(basename $icon .png)/apps/bs-manager.png
    done

    mkdir -p $out/share/bs-manager
    cp -r release/build/*-unpacked/{locales,resources{,.pak}} $out/share/bs-manager

    makeWrapper ${lib.getExe electron} $out/bin/bs-manager \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags $out/share/bs-manager/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix PATH : ${lib.makeBinPath [ steam-run-free ]} \
      --inherit-argv0

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1" # musl-based node modules won't be used on glibc systems
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Game"
      ];

      desktopName = "BSManager";
      exec = "bs-manager";
      icon = "bs-manager";

      mimeTypes = [
        "x-scheme-handler/bsmanager"
        "x-scheme-handler/beatsaver"
        "x-scheme-handler/bsplaylist"
        "x-scheme-handler/modelsaber"
        "x-scheme-handler/web+bsmap"
      ];

      name = "BSManager";
      terminal = false;
      type = "Application";
    })
  ];

  extraNpmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-jE/M22QQzuTS0zgcB+tLEL8Ey61HE8MP7H1MTX060gY=";
    name = "bs-manager-${finalAttrs.version}-extra-npm-deps";
    sourceRoot = "${finalAttrs.src.name}/release/app";
  };

  makeCacheWritable = true;
  npmRebuildFlags = [ "--ignore-scripts" ];

  passthru = {
    depotdownloader = callPackage ./depotdownloader { };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Your Beat Saber Assistant";
    homepage = "https://github.com/Zagrios/bs-manager";
    changelog = "https://github.com/Zagrios/bs-manager/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode # prebuilt node deps
    ];

    maintainers = with lib.maintainers; [
      mistyttm
      Scrumplex
      ImSapphire
      tomasajt
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bs-manager";
  };
})
