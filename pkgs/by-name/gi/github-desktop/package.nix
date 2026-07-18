{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  curl,
  desktopToDarwinBundle,
  electron,
  fetchYarnDeps,
  git,
  git-lfs,
  gnome-keyring,
  libsecret,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  node-gyp,
  nodejs,
  pkg-config,
  python3,
  typescript,
  yarnBuildHook,
  yarnConfigHook,
  zip,
}:

let
  inherit (stdenv.hostPlatform.node) arch platform;
  cacheRootHash = "sha256-/3niIma45fx3cmplxZsSxmnuS+vGtzjF2wqqZ5DcuJI=";
  cacheAppHash = "sha256-/hmUmaPNGoIaIY9qdlP5CG/IKn2nnKCpOqf9Wvj1AwM=";
in

stdenv.mkDerivation (finalAttrs: {
  pname = "github-desktop";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "desktop";
    repo = "desktop";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-S4lWh+6tOP3hw5nAgg6i6//Sd+gaI2aQnoRDQzHsxUg=";
    fetchSubmodules = true;
    postCheckout = "git -C $out rev-parse HEAD > $out/.gitrev";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    yarnBuildHook
    yarnConfigHook

    git
    nodejs
    node-gyp
    pkg-config
    python3
    # desktop-notifications build doesn't pick up tsc from node_modules for some reason
    typescript
    zip
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    gnome-keyring
    libsecret
    curl
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_nodedir = electron.headers;
  };

  postConfigure = ''
    yarnOfflineCache="$cacheRoot" runHook yarnConfigHook

    pushd app
    yarnOfflineCache="$cacheApp" runHook yarnConfigHook
    popd

    yarn --cwd app/node_modules/desktop-notifications run install

    # use git from nixpkgs instead of an automatically downloaded one by dugite
    gitRoot=app/node_modules/dugite/git
    makeWrapper ${lib.getExe git} "$gitRoot/bin/git" \
      --prefix PATH : ${lib.makeBinPath [ git-lfs ]}

    mkdir -p "$gitRoot/libexec/git-core"

    for script in ${git}/libexec/git-core/*; do
      ln -s "$script" "$gitRoot/libexec/git-core/$(basename "$script")"
    done

    # exception: printenvz needs `node-gyp` configure first for some reason
    pushd node_modules/printenvz
    node node_modules/.bin/node-gyp configure
    popd

    declare -a natives=(
      app/node_modules/fs-admin
      app/node_modules/keytar
      app/node_modules/desktop-trampoline
      app/node_modules/windows-argv-parser
      node_modules/printenvz
    )
    for native in "''${natives[@]}"; do
      yarn --offline --cwd $native build
    done

    # exception: desktop-trampoline doesn't include `node-gyp rebuild` in its build script anymore
    pushd app/node_modules/desktop-trampoline
    node-gyp rebuild
    popd

    yarn compile:script

    touch electron
    zip -0Xqr electron-v${electron.version}-${platform}-${arch}.zip electron
    rm electron

    substituteInPlace script/build.ts \
      --replace-fail "return packager({" "return packager({electronZipDir:\"$(pwd)\",electronVersion: \"${electron.version}\","
  '';

  preBuild = ''
    export CIRCLE_SHA1="$(cat .gitrev)"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/github-desktop

    # transpose [name][size] into [size][name]
    for icon in app/static/logos/*.png; do
      size="$(basename "$icon" .png)"
      install -Dm444 "$icon" -T "$out/share/icons/hicolor/$size/github-desktop.png"
    done

    cp -r dist/*/resources $out/share/github-desktop

    makeWrapper ${lib.getExe electron} $out/bin/github-desktop \
      --add-flag $out/share/github-desktop/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    mkdir -p $out/share/icons/hicolor/512x512/apps
    ln -s $out/share/github-desktop/resources/app/static/icon-logo.png $out/share/icons/hicolor/512x512/apps/github-desktop.png

    runHook postInstall
  '';

  cacheApp = fetchYarnDeps {
    hash = cacheAppHash;
    name = "${finalAttrs.pname}-cache-app";
    yarnLock = finalAttrs.src + "/app/yarn.lock";
  };

  cacheRoot = fetchYarnDeps {
    hash = cacheRootHash;
    name = "${finalAttrs.pname}-cache-root";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  desktopItems = [
    (makeDesktopItem {
      comment = "Focus on what matters instead of fighting with Git";
      desktopName = "GitHub Desktop";
      exec = "github-desktop %u";
      icon = "github-desktop";

      mimeTypes = [
        "x-scheme-handler/x-github-client"
        "x-scheme-handler/x-github-desktop-auth"
        "x-scheme-handler/x-github-desktop-dev-auth"
      ];

      name = "github-desktop";
      terminal = false;
    })
  ];

  dontYarnInstallDeps = true;
  yarnBuildScript = "build:prod";

  passthru = {
    inherit (finalAttrs) cacheRoot cacheApp;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        ''^release-(\d+\.\d+\.\d+)$''
        "--custom-dep"
        "cacheRoot"
        "--custom-dep"
        "cacheApp"
      ];
    };
  };

  meta = {
    description = "GUI for managing Git and GitHub";
    homepage = "https://desktop.github.com";
    changelog = "https://desktop.github.com/release-notes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.lists.intersectLists electron.meta.platforms lib.platforms.linux;
    mainProgram = "github-desktop";
    downloadPage = "https://desktop.github.com/download";
  };
})
