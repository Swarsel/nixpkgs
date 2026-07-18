{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  copyDesktopItems,
  electron_41,
  fetchYarnDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs-slim,
  wrapGAppsHook3,
  xcbuild,
  yarnBuildHook,
  yarnConfigHook,
}:

let
  # don't use latest electron to avoid going over the supported abi numbers
  electron = electron_41;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "koodo-reader";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "koodo-reader";
    repo = "koodo-reader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GWhofLT5p8Li0aErJlUQ6E5xSkK4CnnM7UwGDJQBq9I=";
  };

  patches = [
    ./bump-abi-compat.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    nodejs-slim
    nodejs-slim.npm
    (nodejs-slim.python.withPackages (ps: [ ps.setuptools ]))
    yarnConfigHook
    yarnBuildHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    copyDesktopItems
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    xcbuild
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postBuild = ''
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    # we need to build cpu-features with the non-electron headers first
    export npm_config_nodedir=${nodejs-slim}
    npm rebuild --verbose cpu-features

    # register-scheme is an optional dependency of discord-rpc that fails to compile on modern macOS/Electron
    # and is not required for the application's core functionality.
    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      rm -rf node_modules/register-scheme
    ''}

    export npm_config_nodedir=${electron.headers}
    # Explicitly set identity to null to avoid signing on darwin
    yarn --offline run electron-builder --dir \
      -c.mac.identity=null \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      install -Dm644 assets/icons/256x256.png $out/share/icons/hicolor/256x256/apps/koodo-reader.png
      install -Dm644 ${./mime-types.xml} $out/share/mime/packages/koodo-reader.xml

      mkdir -p $out/share/lib/koodo-reader
      cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/lib/koodo-reader
    ''}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -r dist/mac*/"Koodo Reader.app" $out/Applications
      makeWrapper "$out/Applications/Koodo Reader.app/Contents/MacOS/Koodo Reader" $out/bin/koodo-reader
    ''}

    runHook postInstall
  '';

  # we use makeShellWrapper instead of the makeBinaryWrapper provided by wrapGAppsHook for proper shell variable expansion
  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    makeShellWrapper ${lib.getExe electron} $out/bin/koodo-reader \
      --add-flags $out/share/lib/koodo-reader/resources/app.asar \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = finalAttrs.meta.description;
      desktopName = "Koodo Reader";
      exec = "koodo-reader %U";
      icon = "koodo-reader";

      mimeTypes = [
        "application/epub+zip"
        "application/pdf"
        "image/vnd.djvu"
        "application/x-mobipocket-ebook"
        "application/vnd.amazon.ebook"
        "application/x-cbz"
        "application/x-cbr"
        "application/x-cbt"
        "application/x-cb7"
        "application/x-fictionbook+xml"
      ];

      name = "koodo-reader";
      startupWMClass = "Koodo Reader";
      terminal = false;
    })
  ];

  dontWrapGApps = true;

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src patches;
    hash = "sha256-HRWp/lXXPSw2OdvBaEX0W3hnxL9NvIjIk62Dj+rKm1g=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform ebook reader";

    longDescription = ''
      A modern ebook manager and reader with sync and backup capacities
      for Windows, macOS, Linux and Web
    '';

    homepage = "https://github.com/koodo-reader/koodo-reader";
    changelog = "https://github.com/koodo-reader/koodo-reader/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = electron.meta.platforms;
    mainProgram = "koodo-reader";
  };
})
