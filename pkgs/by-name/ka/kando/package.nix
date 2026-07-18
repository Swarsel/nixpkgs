{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cmake,
  copyDesktopItems,
  electron,
  libx11,
  libxi,
  libxkbcommon,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  wayland,
  wayland-scanner,
  zip,
}:

let
  nodejs = nodejs_22; # npm v11 included in nodejs_24 doesn't work with the current lockfile
in
buildNpmPackage.override { inherit nodejs; } rec {
  pname = "kando";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "kando-menu";
    repo = "kando";
    tag = "v${version}";
    hash = "sha256-vmdDcXpSm2O9MkOGfM3+VUrRSvUot1GB0TkxjNSN4r8=";
  };

  patches = [
    ./add-deep-link-note.patch
  ];

  nativeBuildInputs = [
    cmake
    zip
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland-scanner
    copyDesktopItems
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxkbcommon
    libx11
    libxtst
    libxi
    wayland
  ];

  npmDepsHash = "sha256-2J74igNLl5CwXm9WtHzxqTVt7+S113qcioxJja6uUOE=";

  env = {
    # electron-forge's console output is squeezed into one narrow column if unset
    CI = "1";
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # use our own node headers since we skip downloading them
    NIX_CFLAGS_COMPILE = "-I${nodejs}/include/node";
  };

  postConfigure = ''
    # electron files need to be writable on Darwin
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    pushd electron-dist
    zip -0Xqr ../electron.zip .
    popd

    rm -r electron-dist

    # force @electron/packager to use our electron instead of downloading it, even if it is a different version
    substituteInPlace node_modules/@electron/packager/dist/packager.js \
        --replace-fail 'await this.getElectronZipPath(downloadOpts)' '"electron.zip"'

    # don't fetch node headers
    substituteInPlace node_modules/cmake-js/lib/dist.js \
        --replace-fail '!this.downloaded' 'false'
  '';

  # we used --ignore-scripts to have time to patch the dependencies
  # now we'll have to call npm rebuild manually
  preBuild = ''
    npm rebuild --verbose
  '';

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/share/kando
      cp -r out/*/{locales,resources{,.pak}} $out/share/kando

      install -Dm644 assets/icons/icon.svg $out/share/icons/hicolor/scalable/apps/kando.svg

      makeWrapper ${lib.getExe electron} $out/bin/kando \
          --add-flags $out/share/kando/resources/app \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
          --inherit-argv0
    ''}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -r out/*/Kando.app $out/Applications
      makeWrapper $out/Applications/Kando.app/Contents/MacOS/Kando $out/bin/kando
    ''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "The Cross-Platform Pie Menu";
      desktopName = "Kando";
      exec = "kando %U";
      genericName = "Pie Menu";
      icon = "kando";
      mimeTypes = [ "x-scheme-handler/kando" ];
      name = "kando";
    })
  ];

  dontUseCmakeConfigure = true;
  makeCacheWritable = true;
  npmBuildScript = "package";
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Cross-Platform Pie Menu";
    homepage = "https://github.com/kando-menu/kando";
    changelog = "https://github.com/kando-menu/kando/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = electron.meta.platforms;
    mainProgram = "kando";
  };
}
