{
  lib,
  stdenv,
  electron,
  fetchYarnDeps,
  fetchzip,
  fixup-yarn-lock,
  frama-c,
  makeBinaryWrapper,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  yarn,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ivette";
  version = "32.1";

  # Not fetchurl, because we need it unzipped before fetchYarnDeps
  src = fetchzip {
    url = "https://frama-c.com/download/frama-c-${finalAttrs.version}-${finalAttrs.slang}.tar.gz";
    hash = "sha256-D+OJy/pcOqSSexqHVsyCSLSHcMg8zbjKDfmqBZ8xvbk=";
  };

  postPatch = ''
    substituteInPlace src/frama-c/server.ts \
      --replace-fail "command = 'frama-c'" \
      "command = '${lib.getExe frama-c}'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    yarnConfigHook
    nodejs_22
    yarn
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    # From api.sh
    ${lib.getExe frama-c} -server-tsc -server-tsc-out src

    # Run configure.js and sandboxer.js
    make pkg

    # From src/dome/template/makefile:103
    cp ./src/dome/template/react-virtualized.hacked.onScroll.js \
      ./node_modules/react-virtualized/dist/es/WindowScroller/utils/onScroll.js

    DOME=./src/dome DOME_ENV=app yarn --offline run build

    # Workaround for Darwin
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    yarn --offline electron-builder --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p "$out/share/lib/ivette"
    cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/ivette"

    install -Dm444 static/icon.png $out/share/icons/hicolor/512x512/apps/ivette.png

    makeWrapper '${electron}/bin/electron' "$out/bin/ivette" \
      --add-flags "$out/share/lib/ivette/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags "--no-sandbox" \
      --inherit-argv0
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r dist/mac*/Ivette.app "$out/Applications/Ivette.app"
    makeWrapper "$out/Applications/Ivette.app/Contents/MacOS/Ivette" "$out/bin/ivette"
  ''
  + ''
    runHook postInstall
  '';

  __structuredAttrs = true;

  desktopItems = lib.optional stdenv.hostPlatform.isLinux (makeDesktopItem {
    categories = [ "Development" ];
    comment = finalAttrs.meta.description;
    desktopName = "Ivette";
    exec = "ivette";
    genericName = "Frama-C's GUI";
    icon = "ivette";
    name = "ivette";
    startupWMClass = "Ivette";
  });

  slang = "Germanium";
  sourceRoot = "${finalAttrs.src.name}/ivette";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-1NRSTJkXZ1jvkB/7xI0+u4PmrEzKc3VVBdwM50PtznI=";
    yarnLock = "${finalAttrs.src}/ivette/yarn.lock";
  };

  meta = {
    description = "Graphical User Interface for Frama-C";

    longDescription = ''
      Ivette is the Graphical User Interface (GUI) of Frama-C. It
      enables exploring code, augmented with several navigation tools
      and highlighting modes; it allows launching, parametrizing and
      visualizing analyses; and it allows combining them seamlessly,
      taking full advantage of the multi-paradigm approach.
    '';

    homepage = "https://www.frama-c.com/html/ivette.html";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      luc65r
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ivette";
  };
})
