{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron_41,
  jq,
  makeDesktopItem,
  makeWrapper,
  nodejs_24,
}:

let
  description = "Unofficial desktop application for the open-source design tool, Penpot";
  icon = "penpot";
  nodejs = nodejs_24;
  electron = electron_41;
in
buildNpmPackage rec {
  pname = "penpot-desktop";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "author-more";
    repo = "penpot-desktop";
    tag = "v${version}";
    hash = "sha256-/vRF5eqtjdmd2Qmb+OAgKfLJmh78S0WrLWA94SeOJQA=";
  };

  nativeBuildInputs = [
    jq
    nodejs
    makeWrapper
    copyDesktopItems
  ];

  npmDepsHash = "sha256-hu2v2Dw2SRs4Egmsi5hb81vgnZDjQahLXyAYm/uaMao=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  preBuild = ''
    if [[ $(jq --raw-output '.devDependencies.electron' < package.json | grep -E --only-matching '\^[0-9]+' | sed -e 's/\^//') != ${lib.escapeShellArg (lib.versions.major electron.version)} ]]; then
      echo 'ERROR: electron version mismatch'
      exit 1
    fi
  '';

  postBuild = ''
    npm exec electron-builder -- \
      --dir \
      --c.electronDist=${electron.dist} \
      --c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out

    pushd dist/linux-${lib.optionalString stdenv.hostPlatform.isAarch64 "arm64-"}unpacked
    mkdir -p $out/opt/Penpot
    cp -r locales resources{,.pak} $out/opt/Penpot
    popd

    makeWrapper '${lib.getExe electron}' "$out/bin/penpot-desktop" \
      --add-flags $out/opt/Penpot/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    pushd build
    dir=$out/share/icons/hicolor/512x512/apps
    mkdir -p "$dir"
    cp icon.png "$dir"/${icon}.png
    popd

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      inherit icon;
      categories = [ "Graphics" ];
      comment = description;
      desktopName = "Penpot";
      exec = "penpot-desktop %U";
      name = "Penpot";
    })
  ];

  # Do not run the default build script as it leads to errors caused by the electron-builder configuration
  dontNpmBuild = true;
  makeCacheWritable = true;

  npmFlags = [
    "--engine-strict"
    "--legacy-peer-deps"
  ];

  meta = {
    inherit description;
    homepage = "https://github.com/author-more/penpot-desktop";
    changelog = "https://github.com/author-more/penpot-desktop/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ntbbloodbath ];
    platforms = electron.meta.platforms;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "penpot-desktop";
  };
}
