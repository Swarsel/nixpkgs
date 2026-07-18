{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  chromium,
  copyDesktopItems,
  electron,
  ffmpeg,
  # buildInputs
  libsecret,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  # nativeBuildInputs
  node-gyp,
  pkg-config,
  yt-dlp,
}:

buildNpmPackage (finalAttrs: {
  pname = "Sharedown";
  version = "5.3.6-unstable-2025-12-16";

  src = fetchFromGitHub {
    owner = "kylon";
    repo = "Sharedown";
    rev = "5d0cbe2d25de6e288e35bd549f436b090d6e287a";
    hash = "sha256-yHnTS3B3lWSkAVlUNQYFuKIHM96d1ZeVWImJqXjlfMw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    node-gyp
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libsecret
  ];

  npmDepsHash = "sha256-YmrSIOi9WpqDPC9Tj1oTprdCFDdYj6C91kg567+/3ik=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";
  };

  postInstall = ''
    install -Dm0644 build/icon.png $out/share/icons/hicolor/512x512/apps/Sharedown.png

    # Create a launcher wrapper
    makeWrapper ${electron}/bin/electron $out/bin/sharedown \
      --add-flags $out/lib/node_modules/sharedown/app.js \
      --set PUPPETEER_EXECUTABLE_PATH ${chromium}/bin/chromium \
      --prefix PATH : ${lib.makeBinPath finalAttrs.finalPackage.passthru.wrapperPaths} \
      --add-flags "--no-sandbox"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        # Based upon categories in upstream's package.json
        "AudioVideo"
      ];

      comment = "An Application to save your Sharepoint videos for offline usage.";
      desktopName = "Sharedown";
      exec = "Sharedown";
      icon = "Sharedown";
      name = "Sharedown";
    })
  ];

  dontNpmBuild = true;

  passthru = {
    updateScript = nix-update-script {
      # Updates are not very frequent, so we wish to track the latest git
      # commit.
      extraArgs = [
        "--version=branch"
      ];
    };

    wrapperPaths = [
      ffmpeg
      yt-dlp
      chromium
    ];
  };

  meta = {
    description = "Application to save your Sharepoint videos for offline usage";
    homepage = "https://github.com/kylon/Sharedown";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "Sharedown";
  };
})
