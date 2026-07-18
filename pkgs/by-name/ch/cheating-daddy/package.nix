{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  python3,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "cheating-daddy";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "sohzm";
    repo = "cheating-daddy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/xH3tBnZAnDr/EbewtJc0WpBirW1Obn6tka7NP0ovAc=";
  };

  patches = [
    # zip extraction fails on newer nodejs versions without this fix
    ./bump-yauzl.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    (python3.withPackages (ps: with ps; [ setuptools ]))
    zip
  ];

  npmDepsHash = "sha256-p26yEuIiK7baeAxf06E+cmuzl45NS2WOmWNeFfTplQA=";

  env = {
    # electron-forge's console output is squeezed into one narrow column if unset
    CI = "1";
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ONNXRUNTIME_NODE_INSTALL = "skip";
    ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
  };

  preBuild = ''
    cp --recursive --no-preserve=mode ${electron.dist} electron-dist
    pushd electron-dist
    zip -0Xqr ../electron.zip .
    popd
    rm --recursive electron-dist
    substituteInPlace node_modules/@electron/packager/dist/packager.js \
      --replace-fail "await this.getElectronZipPath(downloadOpts)" "\"$(pwd)/electron.zip\""
  '';

  buildPhase = ''
    runHook preBuild

    npm run package

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/cheating-daddy
    cp --recursive out/*/{locales,resources{,.pak}} $out/share/cheating-daddy
    makeWrapper ${lib.getExe electron} $out/bin/cheating-daddy \
      --add-flags $out/share/cheating-daddy/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --inherit-argv0
    install -D --mode=0644 src/assets/logo.png $out/share/icons/hicolor/512x512/apps/cheating-daddy.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Education"
      ];

      comment = "AI assistant for interviews and learning";
      desktopName = "Cheating Daddy";
      exec = "cheating-daddy";
      genericName = "AI Assistant";
      icon = "cheating-daddy";
      name = "cheating-daddy";
      terminal = false;
    })
  ];

  makeCacheWritable = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Real-time AI assistant that provides contextual help during video calls, interviews, presentations, and meetings using screen capture and audio analysis";
    homepage = "https://github.com/sohzm/cheating-daddy";
    changelog = "https://github.com/sohzm/cheating-daddy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kyehn ];
    platforms = lib.platforms.linux;
    mainProgram = "cheating-daddy";
  };
})
