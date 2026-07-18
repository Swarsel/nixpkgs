{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  kopia,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:
let
  version = "0.23.1";
  src = fetchFromGitHub {
    owner = "kopia";
    repo = "kopia";
    tag = "v${version}";
    hash = "sha256-yjeLV7N/U88oVdP4iJYgSM/QJLAMREaB/2jBcbTDWkA=";
  };
in
buildNpmPackage {
  inherit version src;
  pname = "kopia-ui";
  patches = [ ./fix-paths.patch ];

  postPatch = ''
    substituteInPlace public/utils.js --replace-fail KOPIA ${lib.getExe kopia}
  '';

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  npmDepsHash = "sha256-yj5+qiLfy6CjAOXIzT9OMu860Pefwn+HuJNoBAizb/0=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  buildPhase = ''
    runHook preBuild
    cp -r ${electron.dist} electron-dist
    chmod -R u+w ..
    npm exec electron-builder -- \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.extraMetadata.version=v${version}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/kopia
    cp -r ../dist/kopia-ui/*-unpacked/{locales,resources{,.pak}} $out/share/kopia
    install -Dm644 $src/icons/kopia.svg $out/share/icons/hicolor/scalable/apps/kopia.svg
    makeWrapper ${lib.getExe electron} $out/bin/kopia-ui \
      --prefix PATH : ${lib.makeBinPath [ kopia ]} \
      --add-flags $out/share/kopia/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Fast and secure open source backup.";
      desktopName = "KopiaUI";
      exec = "kopia-ui";
      icon = "kopia";
      name = "kopia-ui";
      type = "Application";
    })
  ];

  makeCacheWritable = true;
  sourceRoot = "${src.name}/app";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform backup tool with fast, incremental backups, client-side end-to-end encryption, compression and data deduplication";
    homepage = "https://kopia.io";
    changelog = "https://github.com/kopia/kopia/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kilyanni ];
    platforms = lib.platforms.linux;
    mainProgram = "kopia-ui";
    downloadPage = "https://github.com/kopia/kopia";
  };
}
