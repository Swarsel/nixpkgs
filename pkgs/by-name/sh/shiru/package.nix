{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  electron_42,
  fetchPnpmDeps,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  python3,
}:
let
  pnpm = pnpm_10;
  electron = electron_42;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shiru";
  version = "6.7.1";

  src = fetchFromGitHub {
    owner = "RockinChaos";
    repo = "shiru";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hlxwpTQp8ZD1dGeo2eKeE7MPZSi/qV74Q+5NEox5UkY=";
  };

  patches = [
    # electron-shutdown-handler is only used on Windows and tries to download
    # files during build
    ./0001-Remove-Windows-specific-dep.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    python3
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildPhase = ''
    runHook preBuild

    cd electron

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm run web:build

    ./node_modules/.bin/electron-builder --dir \
      --c.electronDist=electron-dist \
      --c.electronVersion=${electron.version} \
      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        --c.npmRebuild=false \
        --c.mac.identity=null \
        --c.mac.notarize=false \
      ''}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mkdir -p "$out/share/lib/shiru"
    cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/shiru"

    install -Dm644 buildResources/icon.png "$out/share/icons/hicolor/512x512/apps/shiru.png"

    makeWrapper '${electron}/bin/electron' "$out/bin/shiru" \
      --add-flags "$out/share/lib/shiru/resources/app.asar" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      --inherit-argv0
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/Applications"
    cp -r dist/mac*/Shiru.app "$out/Applications/"

    mkdir -p "$out/bin"
    makeWrapper \
      "$out/Applications/Shiru.app/Contents/MacOS/Shiru" \
      "$out/bin/shiru" \
      --set-default ELECTRON_IS_DEV 0
  ''
  + ''
    runHook postInstall
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Video"
        "AudioVideo"
      ];

      comment = "Manage your personal media library, organize your collection, and stream your content in real time, no waiting required!";
      desktopName = "Shiru";
      exec = "shiru %U";
      genericName = "Personal Media Library";
      icon = "shiru";
      keywords = [ "Anime" ];
      mimeTypes = [ "x-scheme-handler/shiru" ];
      name = "shiru";
    })
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-dBoVmqSnJG0KsvLuZQVoZWX4m1BEqLYumofbNHgPgz0=";

    prePnpmInstall = ''
      cd electron
    '';
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stream your personal media library in real-time";
    homepage = "https://github.com/RockinChaos/Shiru";
    changelog = "https://github.com/RockinChaos/Shiru/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      naomieow
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "shiru";
  };
})
