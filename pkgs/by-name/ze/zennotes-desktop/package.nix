{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron_41,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  installCli ? false,
}:

buildNpmPackage (finalAttrs: {
  pname = "zennotes-desktop";
  version = "2.13.2";

  src = fetchFromGitHub {
    owner = "ZenNotes";
    repo = "zennotes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wazp3v6fV0gBh4ASlinhmA6SnGDmBvRcWFEXbENQUII=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  npmDepsHash = "sha256-7dchbcGAZm+PlVsES76sYD9NOqeCulEKC7S0zLERvvY=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/zennotes-monorepo
    cp -r . $out/lib/node_modules/zennotes-monorepo/

    for icon in apps/desktop/build/icons/*.png; do
      size="$(basename "$icon" .png)"
      install -Dm644 $icon $out/share/icons/hicolor/$size/apps/zennotes-desktop.png
    done

    mkdir -p $out/bin
    makeWrapper ${electron_41}/bin/electron $out/bin/zennotes-desktop \
      --add-flags "$out/lib/node_modules/zennotes-monorepo/apps/desktop"

    ${lib.optionalString installCli ''
      makeWrapper ${electron_41}/libexec/electron/electron $out/bin/zn \
        --set ELECTRON_RUN_AS_NODE 1 \
        --add-flags "$out/lib/node_modules/zennotes-monorepo/apps/desktop/out/main/cli.js"
    ''}

    runHook postInstall
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "Utility"
        "TextEditor"
      ];

      comment = "Keyboard-first local Markdown notes";
      desktopName = "ZenNotes";
      exec = "zennotes-desktop %U";
      icon = "zennotes-desktop";

      mimeTypes = [
        "text/markdown"
        "x-scheme-handler/zennotes"
      ];

      name = "zennotes-desktop";
      startupWMClass = "ZenNotes";
    })
  ];

  npmWorkspace = "apps/desktop";
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Keyboard-first local Markdown notes with Vim motions, diagrams, and MCP integration";
    homepage = "https://zennotes.org/";
    changelog = "https://github.com/ZenNotes/zennotes/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      justkrysteq
      Br1ght0ne
      ad030
    ];

    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "zennotes-desktop";
  };
})
