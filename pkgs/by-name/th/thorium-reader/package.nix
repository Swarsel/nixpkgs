{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  desktopToDarwinBundle,
  electron,
  makeBinaryWrapper,
  makeDesktopItem,
  makeShellWrapper,
  nodejs_24,
}:

buildNpmPackage (finalAttrs: {
  pname = "thorium-reader";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "edrlab";
    repo = "thorium-reader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h285GM7DKKD34Wjw6E+zSSIGkUH/UOesLrYD2EdQ7+U=";
  };

  # The upstream `build` script re-runs `npm i` inside `dist/` to populate
  # `dist/node_modules` with the runtime subset declared in `src/package.json`.
  # This is bad (not reproducible), so we strip that segment from the `build`
  # script. This ends up not being an issue, since our build/install process
  # copies relevant dependencies anyways.
  patches = [ ./remove-dist-npm-install.patch ];

  # makeBinaryWrapper is required on Darwin since MacOS is confuses itself
  # into thinking it needs Rosetta 2 if it encounters a non-MachO executable
  # in a .app bundle.
  # Simultaneously, we need makeShellWrapper on linux platforms to pass
  # electron-specific flags.
  nativeBuildInputs = [
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    makeShellWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
    desktopToDarwinBundle
  ];

  npmDepsHash = "sha256-IwdU77fRJJ7Ch5rWop3lFpf14XHklFDa8w6YJCFtJRU=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postBuild = ''
    # copy node modules manually
    cp -r node_modules dist/node_modules

    # remove unnecessary npm deps
    pushd dist
    npm prune --production --ignore-scripts --offline --no-audit --no-fund
    popd
  '';

  postInstall =
    let
      ozoneFlags = lib.optionalString stdenv.hostPlatform.isLinux ''--add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"'';
    in
    ''
      install -Dpm644 resources/icon.png $out/share/icons/thorium-reader.png

      cp -r dist/* $out/lib/node_modules/EDRLab.ThoriumReader/

      ${
        if stdenv.hostPlatform.isDarwin then "makeBinaryWrapper" else "makeWrapper"
      } '${lib.getExe electron}' "$out/bin/thorium-reader" \
        --add-flags $out/lib/node_modules/EDRLab.ThoriumReader \
        ${ozoneFlags} \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = "Desktop application to read ebooks";
      desktopName = "Thorium";
      exec = "thorium-reader %u";
      icon = "thorium-reader";

      mimeTypes = [
        "application/epub+zip"
        "application/daisy+zip"
        "application/vnd.readium.lcp.license.v1.0+json"
        "application/audiobook+zip"
        "application/webpub+zip"
        "application/audiobook+lcp"
        "application/pdf+lcp"
        "x-scheme-handler/thorium"
        "x-scheme-handler/opds"
      ];

      name = "thorium-reader";
      startupWMClass = "thorium-reader";
      terminal = false;
      type = "Application";
    })
  ];

  makeCacheWritable = true;
  nodejs = nodejs_24;

  meta = {
    description = "EPUB reader";
    homepage = "https://www.edrlab.org/software/thorium-reader/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      YodaDaCoda
      agarmu
    ];

    platforms = lib.platforms.all;
    mainProgram = "thorium-reader";
  };
})
