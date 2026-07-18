{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  electron,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeDesktopItem,
  makeWrapper,
  nodejs,
  typescript,
  yarn,
}:
# NOTE mqtt-explorer has 3 yarn subpackages and uses relative links
# between them, which makes it hard to package them via 3 `fetchYarnDeps`
# since the resulting `node_modules` directories don't have the same structure
# as if they were installed directly. Hence why we opted to use a
# `stdenv.mkDerivation` instead.
stdenv.mkDerivation rec {
  # NOTE official app name is `MQTT-Explorer` but to suffice nixpkgs conventions
  # we opted to use `mqtt-explorer` instead.
  pname = "mqtt-explorer";
  version = "0.4.0-beta.6";

  src = fetchFromGitHub {
    owner = "thomasnordquist";
    repo = "MQTT-Explorer";
    rev = "v${version}";
    hash = "sha256-oFS4RnuWQoicPemZbPBAp8yQjRbhAyo/jiaw8V0MBAo=";
  };

  nativeBuildInputs = [
    nodejs
    yarn
    typescript
    fixup-yarn-lock
    makeWrapper
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ copyDesktopItems ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    tsc && cd app && yarn --offline run build && cd ..

    yarn --offline run electron-builder --dir \
      -c.electronDist="$electron_dist" \
      -c.electronVersion=${electron.version} \
      -c.mac.identity=null
    # ^ disable code signing on macos

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    export ELECTRON_OVERRIDE_DIST_PATH="$electron_dist"

    yarn test:app --offline
    yarn test:backend --offline

    unset ELECTRON_OVERRIDE_DIST_PATH
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      mkdir -p "$out/share/mqtt-explorer"/{app,icons/hicolor}

      cp -r build/*-unpacked/{locales,resources{,.pak}} "$out/share/mqtt-explorer/app"

      for file in res/appx/Square44x44Logo.targetsize-*_altform-unplated.png; do

        size=$(echo "$file" | sed -n 's/.*targetsize-\([0-9]*\)_altform-unplated\.png/\1/p')

        install -Dm644 \
          "$file" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/mqtt-explorer.png"
      done

      makeWrapper '${electron}/bin/electron' "$out/bin/mqtt-explorer" \
        --add-flags "$out/share/mqtt-explorer/app/resources/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0
    ''}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/{Applications,bin}
      mv build/mac*/MQTT\ Explorer.app $out/Applications

      makeWrapper "$out/Applications/MQTT Explorer.app/Contents/MacOS/MQTT Explorer" \
        $out/bin/mqtt-explorer
    ''}

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    # Yarn writes cache directories etc to $HOME.
    export HOME=$TMPDIR

    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror $offlineCache
    yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress

    pushd app
    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror $offlineCacheApp
    yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress
    popd

    pushd backend
    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror $offlineCacheApp
    yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress
    popd

    patchShebangs {node_modules,app/node_modules,backend/node_modules}

    electron_dist="$(mktemp -d)"
    cp -r ${electron.dist}/. "$electron_dist"
    chmod -R u+w "$electron_dist"

    runHook postConfigure
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Utility"
        "Network"
      ];

      comment = meta.description;
      desktopName = "MQTT Explorer";
      exec = meta.mainProgram;
      genericName = "MQTT Protocol Client";
      icon = "mqtt-explorer";
      name = pname;
      startupWMClass = "mqtt-explorer";
      type = "Application";
    })
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-yEL6Vb1Yry3Vns2GF0aagGksRwsCgXR5ZfmrDPxeqos=";
    yarnLock = "${src}/yarn.lock";
  };

  offlineCacheApp = fetchYarnDeps {
    hash = "sha256-4oGWBXZHdN+wSpn3fPzTdpaIcywAVdFVYmsOIhcgvUE=";
    yarnLock = "${src}/app/yarn.lock";
  };

  offlineCacheBackend = fetchYarnDeps {
    hash = "sha256-gg6KrcQz7MdIgFdlbuGiDf/tVd7lSOjwXFIq56tpaTc=";
    yarnLock = "${src}/backend/yarn.lock";
  };

  meta = {
    description = "All-round MQTT client that provides a structured topic overview";
    homepage = "https://github.com/thomasnordquist/MQTT-Explorer";
    changelog = "https://github.com/thomasnordquist/MQTT-Explorer/releases/tag/v${version}";
    license = lib.licenses.cc-by-nd-40;
    maintainers = with lib.maintainers; [ tsandrini ];
    platforms = electron.meta.platforms;
    mainProgram = "mqtt-explorer";
  };
}
