{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cairo,
  clang_20,
  copyDesktopItems,
  electron,
  jq,
  makeDesktopItem,
  makeWrapper,
  moreutils,
  nix-update-script,
  nodejs_22,
  npm-lockfile-fix,
  pango,
  pixman,
  pkg-config,
}:

buildNpmPackage rec {
  pname = "bruno";
  version = "3.5.2";

  src = fetchFromGitHub {
    owner = "usebruno";
    repo = "bruno";
    tag = "v${version}";
    hash = "sha256-Lll/ywDkHv0xvLk8iiBEySek7A3dBmfO4V/q2xaNtBQ=";

    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/package-lock.json
    '';
  };

  postPatch = ''
    substituteInPlace scripts/build-electron.sh \
      --replace-fail 'if [ "$1" == "snap" ]; then' 'exit 0; if [ "$1" == "snap" ]; then'

    # disable telemetry
    substituteInPlace packages/bruno-app/src/providers/App/index.js \
      --replace-fail "useTelemetry({ version });" ""

    # fix version reported in sidebar and about page
    ${jq}/bin/jq '.version |= "${version}"' packages/bruno-electron/package.json | ${moreutils}/bin/sponge packages/bruno-electron/package.json
    ${jq}/bin/jq '.version |= "${version}"' packages/bruno-app/package.json | ${moreutils}/bin/sponge packages/bruno-app/package.json
  '';

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin clang_20 # clang_21 breaks gyp builds
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    pixman
    cairo
    pango
  ];

  npmDepsHash = "sha256-4VsSXiHj/INCu4ryZ+JxPbfDpsgIb5eYvOUYz+gbKEE=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  postConfigure = ''
    # sh: line 1: /build/source/packages/bruno-common/node_modules/.bin/rollup: cannot execute: required file not found
    patchShebangs packages/*/node_modules
  '';

  preBuild = ''
    # upstream keeps removing and adding back canvas, only patch it when it is present
    if [[ -e node_modules/canvas/binding.gyp ]]; then
      substituteInPlace node_modules/canvas/binding.gyp \
        --replace-fail "'with_gif%': '<!(node ./util/has_lib.js gif)'" "'with_gif%': 'false'"
      npm rebuild
    fi
  '';

  buildPhase = ''
    runHook preBuild

    npm run build --workspace=packages/bruno-common
    npm run build --workspace=packages/bruno-graphql-docs
    npm run build --workspace=packages/bruno-schema-types
    npm run build --workspace=packages/bruno-converters
    npm run build --workspace=packages/bruno-app
    npm run build --workspace=packages/bruno-query
    npm run build --workspace=packages/bruno-filestore
    npm run build --workspace=packages/bruno-requests

    npm run sandbox:bundle-libraries --workspace=packages/bruno-js

    bash scripts/build-electron.sh

    pushd packages/bruno-electron

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          cp -r ${electron.dist}/Electron.app ./
          find ./Electron.app -name 'Info.plist' | xargs -d '\n' chmod +rw

          substituteInPlace electron-builder-config.js \
            --replace-fail "identity: 'Anoop MD (W7LPPWA48L)'" 'identity: null' \
            --replace-fail "afterSign: 'notarize.js'," ""

          npm exec electron-builder -- \
            --dir \
            --config electron-builder-config.js \
            -c.electronDist=./ \
            -c.electronVersion=${electron.version} \
            -c.npmRebuild=false
        ''
      else
        ''
          npm exec electron-builder -- \
            --dir \
            -c.electronDist=${electron.dist} \
            -c.electronVersion=${electron.version} \
            -c.npmRebuild=false
        ''
    }

    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/Applications

          cp -R packages/bruno-electron/out/**/Bruno.app $out/Applications/
        ''
      else
        ''
          mkdir -p $out/opt/bruno $out/bin

          cp -r packages/bruno-electron/dist/linux*-unpacked/{locales,resources{,.pak}} $out/opt/bruno

          makeWrapper ${lib.getExe electron} $out/bin/bruno \
            --add-flags $out/opt/bruno/resources/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
            --prefix LD_LIBRARY_PATH : ${
              lib.makeLibraryPath [
                stdenv.cc.cc.lib
              ]
            } \
            --set-default ELECTRON_IS_DEV 0 \
            --inherit-argv0

          for s in 16 32 48 64 128 256 512 1024; do
            size=${"$"}{s}x$s
            install -Dm644 $src/packages/bruno-electron/resources/icons/png/$size.png $out/share/icons/hicolor/$size/apps/bruno.png
          done
        ''
    }

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = "Opensource API Client for Exploring and Testing APIs";
      desktopName = "Bruno";
      exec = "bruno %U";
      icon = "bruno";
      name = "bruno";
      startupWMClass = "Bruno";
    })
  ];

  nodejs = nodejs_22;
  npmFlags = [ "--legacy-peer-deps" ];
  npmPackFlags = [ "--ignore-scripts" ];
  # remove giflib dependency
  npmRebuildFlags = [ "--ignore-scripts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source IDE For exploring and testing APIs";
    homepage = "https://www.usebruno.com";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gepbird
      kashw2
      mattpolzin
      redyf
      water-sucks
      starsep
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "bruno";
  };
}
