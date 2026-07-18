{
  lib,
  stdenv,
  fetchFromGitHub,
  anytype-heart,
  bun,
  copyDesktopItems,
  coreutils,
  electron,
  go,
  libsecret,
  lsof,
  makeDesktopItem,
  makeWrapper,
  node-gyp,
  nodejs,
  pkg-config,
  protobuf,
  python3,
  stdenvNoCC,
  writableTmpDirAsHomeHook,
  commandLineArgs ? "",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anytype";
  version = "0.55.5";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-ts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9myOd7LTH/NoRY4SjU7+FSSNIhDMGKRPTBOQOURk/Hs=";
  };

  patches = [
    ./0001-feat-update-Disable-auto-checking-for-updates-and-updating-manually.patch
    ./0002-remove-grpc-devtools.patch
    ./0003-remove-desktop-entry.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    bun
    nodejs
    pkg-config
    go
    protobuf
    copyDesktopItems
    makeWrapper
    node-gyp
    stdenv.cc
    python3
  ];

  buildInputs = [
    libsecret
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # used upstream for builds: https://github.com/anyproto/anytype-ts/blob/5d66657f764c0649410e37c9e9c06e3ff18487ee/.github/workflows/build.yml#L192.
    NODE_OPTIONS = "--max-old-space-size=8192";
  };

  buildPhase = ''
    runHook preBuild

    # Building keytar against electron's ABI
    # Trying to build in temp dir, will not work due to the keytar calling the node -p require('node-addon-api').include_dir
    # but building inside the node_modules/keytar will find the ../node-addon-api automatically
    chmod -R u+w node_modules/keytar node_modules/node-addon-api
    pushd node_modules/keytar
    HOME=$(mktemp -d) node-gyp rebuild --nodedir=${electron.headers}
    popd

    substituteInPlace scripts/generate-protos.sh \
      --replace-fail "/usr/bin/env" "${coreutils}/bin/env"

    cp -r ${anytype-heart}/lib dist/
    cp -r ${anytype-heart}/bin/anytypeHelper dist/

    # Without this, build fails when trying to copy/write into that directory during the js bundle step
    chmod -R u+w dist/

    bash ./scripts/generate-protos.sh --from-dist

    bun run build

    for lang in ${finalAttrs.locales}/locales/*; do
      cp "$lang" "dist/lib/json/lang/$(basename $lang)"
    done

    # $HOME/.cache/go-build.
    export GOCACHE=$(mktemp -d)
    # Runs "go build -o dist/nativeMessagingHost ./go/nativeMessagingHost.go"
    bun run build:nmh

    runHook postBuild
  '';

  # remove unnecessary files
  preInstall = ''
    chmod u+w -R dist node_modules
    find -type f \( -name "*.ts" -o -name "*.map" \) -exec rm -rf {} +
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/anytype
    cp -r electron.js electron dist node_modules package.json $out/lib/anytype/

    for icon in $out/lib/anytype/electron/img/icons/*.png; do
      mkdir -p "$out/share/icons/hicolor/$(basename $icon .png)/apps"
      ln -s "$icon" "$out/share/icons/hicolor/$(basename $icon .png)/apps/anytype.png"
    done

    cp LICENSE.md $out/share

    makeWrapper '${lib.getExe electron}' $out/bin/anytype \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags $out/lib/anytype/ \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    wrapProgram $out/lib/anytype/dist/nativeMessagingHost \
      --prefix PATH : ${lib.makeBinPath [ lsof ]}

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .
    patchShebangs node_modules

    runHook postConfigure
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Office"
        "Calendar"
        "ProjectManagement"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Anytype";
      exec = "anytype %U";
      icon = "anytype";
      mimeTypes = [ "x-scheme-handler/anytype" ];
      name = "anytype";
      startupWMClass = "anytype";
    })
  ];

  locales = fetchFromGitHub {
    hash = "sha256-+vkProHi25CWxG74QB5eo0Pnwj0u5vXoZeeCoXyMOv4=";
    owner = "anyproto";
    repo = "l10n-anytype-ts";
    rev = "b96bf7b76f10e764e7a60c7f284854aaabedcec6";
  };

  node_modules = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      # https://bun.com/docs/pm/cli/install#configuring-with-environment-variables

      # Bun always tries to use the fastest available installation method for the target platform. On macOS, that’s clonefile and on Linux, that’s hardlink.
      bun install \
        --backend=copyfile \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontConfigure = true;
    dontFixup = true;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    outputHash = "sha256-6IHFidjVDDzUOCRXVwjvzcLGKV6dWWS7k2jwrOuJ748=";
    outputHashMode = "recursive";
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "P2P note-taking tool";
    homepage = "https://anytype.io/";
    changelog = "https://github.com/anyproto/anytype-ts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unfreeRedistributable;

    maintainers = with lib.maintainers; [
      autrimpo
      adda
      kira-bruneau
      xmnlz
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "anytype";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
