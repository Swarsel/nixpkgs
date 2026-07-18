{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  electron,
  fetchYarnDeps,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation rec {
  pname = "kuro";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "davidsmorais";
    repo = "kuro";
    rev = "v${version}";
    hash = "sha256-9Z/r5T5ZI5aBghHmwiJcft/x/wTRzDlbIupujN2RFfU=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall

    # resources
    mkdir -p "$out/share/lib/kuro"
    cp -r ./dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/kuro"

    # icons
    magick static/Icon.png -resize 512x512 kuro.png # original icon is 1024x1024, which isn't supported by hicolor
    install -Dm444 kuro.png $out/share/icons/hicolor/512x512/apps/kuro.png

    # executable wrapper
    makeWrapper '${electron}/bin/electron' "$out/bin/kuro" \
      --add-flags "$out/share/lib/kuro/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = meta.description;
      desktopName = "Kuro";
      exec = "kuro";
      genericName = "Microsoft To-Do Client";
      icon = "kuro";
      name = "kuro";
      startupWMClass = "kuro";
    })
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-GTiNv7u1QK/wjQgpka7REuoLn2wjZG59kYJQaZZPycI=";
    yarnLock = "${src}/yarn.lock";
  };

  yarnBuildFlags = [
    "--dir"
    "-c.electronDist=${electron.dist}"
    "-c.electronVersion=${electron.version}"
  ];

  yarnBuildScript = "electron-builder";

  meta = {
    inherit (electron.meta) platforms;
    description = "Unofficial, featureful, open source, community-driven, free Microsoft To-Do app";
    homepage = "https://github.com/davidsmorais/kuro";
    changelog = "https://github.com/davidsmorais/kuro/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ChaosAttractor ];
    mainProgram = "kuro";
  };
}
