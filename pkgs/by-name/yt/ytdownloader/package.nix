{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  ffmpeg-headless,
  makeDesktopItem,
  makeWrapper,
  yt-dlp,
}:

buildNpmPackage rec {
  pname = "ytDownloader";
  version = "3.19.3";

  src = fetchFromGitHub {
    owner = "aandrew-me";
    repo = "ytDownloader";
    tag = "v${version}";
    hash = "sha256-6HYVNtjGOQICiby4je3iYG9mPGMEXWTY+87HuUMaA2A=";
  };

  # Patch config dir to ~/.config/ytdownloader
  # Otherwise it stores config in ~/.config/Electron
  patches = [ ./config-dir.patch ];

  # Replace hardcoded ffmpeg and ytdlp paths
  # Also stop it from downloading ytdlp
  postPatch = ''
    substituteInPlace src/renderer.js \
      --replace-fail $\{__dirname}/../ffmpeg '${lib.getExe ffmpeg-headless}' \
      --replace-fail 'path.join(os.homedir(), ".ytDownloader", "ytdlp")' '`${lib.getExe yt-dlp}`' \
      --replace-fail 'let ytDlpIsPresent = false;' 'let ytDlpIsPresent = true;'
    # Disable auto-updates
    substituteInPlace src/preferences.js \
      --replace-warn 'const autoUpdateDisabled = getId("autoUpdateDisabled");' 'const autoUpdateDisabled = "true";'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    ffmpeg-headless
    yt-dlp
  ];

  npmDepsHash = "sha256-FiWtZBixg7iz/9YgqnhIIG6MYNql7ITOUXH7aBBv7Co=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/ytdownloader \
        --add-flags $out/lib/node_modules/ytdownloader/main.js \
        --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}

    install -Dm444 assets/images/icon.png $out/share/icons/hicolor/512x512/apps/ytdownloader.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "A modern GUI video and audio downloader";
      desktopName = "ytDownloader";
      exec = "ytdownloader %U";
      icon = "ytdownloader";
      name = "ytDownloader";
      startupWMClass = "ytDownloader";
    })
  ];

  dontNpmBuild = true;
  makeCacheWritable = true;

  meta = {
    description = "Modern GUI video and audio downloader";
    homepage = "https://github.com/aandrew-me/ytDownloader";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "ytdownloader";
  };
}
