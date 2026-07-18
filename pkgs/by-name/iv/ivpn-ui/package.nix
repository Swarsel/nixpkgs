{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  ivpn-service,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "ivpn-ui";
  version = "3.15.6";

  src = fetchFromGitHub {
    owner = "ivpn";
    repo = "desktop-app";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C24klcr10i0lki74eNfJ4bappdIttp3S4FGg1wkAGcY=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  npmDepsHash = "sha256-S/fB3MxEDLVEZ762EkBkyemYW2rgBGtCH5y/6p6nqgE=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  postBuild = ''
    electron_dist="$(mktemp -d)"
    cp -r ${electron.dist}/. "$electron_dist"
    chmod -R u+w "$electron_dist"

    npm exec electron-builder -- \
      --dir \
      -c.electronDist="$electron_dist" \
      -c.electronVersion=${electron.version} \
      --config electron-builder.config.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ivpn-ui
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/ivpn-ui

    install -Dm644 $src/ui/References/Linux/ui/ivpnicon.svg $out/share/icons/hicolor/scalable/apps/ivpn-ui.svg

    makeWrapper ${lib.getExe electron} $out/bin/ivpn-ui \
      --prefix PATH : ${lib.makeBinPath [ ivpn-service ]} \
      --add-flags $out/share/ivpn-ui/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = "UI interface for IVPN";
      desktopName = "IVPN";
      exec = "ivpn-ui";
      genericName = "VPN Client";
      icon = "ivpn-ui";
      name = "ivpn-ui";
      startupNotify = true;
      type = "Application";
    })
  ];

  sourceRoot = "source/ui";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "UI interface for IVPN";
    homepage = "https://www.ivpn.net";
    changelog = "https://github.com/ivpn/desktop-app/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kilyanni ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ivpn-ui";
    downloadPage = "https://github.com/ivpn/desktop-app";
  };
})
