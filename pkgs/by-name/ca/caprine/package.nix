{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "caprine";
  version = "2.61.0";

  src = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "caprine";
    rev = "v${version}";
    hash = "sha256-hBGsqOqKMHNy2SNw1kHCQq1lPDd2S36L5pdKgD2O8FA=";
  };

  patches = [ ./001-disable-auto-update.patch ];
  nativeBuildInputs = [ copyDesktopItems ];
  npmDepsHash = "sha256-FgOHuMMUX92VHF6hdznoi7bhO/27t6+l038kmpqjctQ=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postBuild = ''
    electron_dist="$(mktemp -d)"
    cp -r ${electron.dist}/. "$electron_dist"
    chmod -R u+w "$electron_dist"

    npm exec electron-builder -- \
        --dir \
        -c.npmRebuild=true \
        -c.asarUnpack="**/*.node" \
        -c.electronDist="$electron_dist" \
        -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/share/caprine
      cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/caprine

      makeWrapper ${lib.getExe electron} $out/bin/caprine \
          --add-flags $out/share/caprine/resources/app.asar \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
          --set-default ELECTRON_IS_DEV 0 \
          --inherit-argv0

      install -Dm644 build/icon.png $out/share/icons/hicolor/512x512/apps/caprine.png
    ''}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -r dist/mac*/"Caprine.app" $out/Applications
      makeWrapper "$out/Applications/Caprine.app/Contents/MacOS/Caprine" $out/bin/caprine
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];

      comment = meta.description;
      desktopName = "Caprine";
      exec = "caprine %U";
      icon = "caprine";
      mimeTypes = [ "x-scheme-handler/caprine" ];
      name = "caprine";
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (electron.meta) platforms;
    description = "Elegant Facebook Messenger desktop app";
    homepage = "https://github.com/sindresorhus/caprine";
    changelog = "https://github.com/sindresorhus/caprine/releases/tag/${src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      khaneliman
    ];
  };
}
