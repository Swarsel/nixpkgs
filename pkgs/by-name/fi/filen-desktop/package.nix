{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cairo,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  makeWrapper,
  pango,
  pixman,
  pkg-config,
}:
let
  packageName = "filen-desktop";
  packageVersion = "3.0.47";
  desktopName = "Filen Desktop";
  appName = "Filen";

  desktopItem = makeDesktopItem {
    categories = [
      "Network"
      "FileTransfer"
      "Utility"
    ];

    comment = "Encrypted Cloud Storage";
    desktopName = desktopName;
    exec = packageName;
    icon = packageName;

    keywords = [
      "cloud"
      "storage"
      "encrypted"
    ];

    name = packageName;
    startupWMClass = packageName;
  };
in
buildNpmPackage {
  pname = packageName;
  version = packageVersion;

  src = fetchFromGitHub {
    owner = "FilenCloudDienste";
    repo = packageName;
    rev = "v${packageVersion}";
    hash = "sha256-WS9JqErfsRtt6zF+LrKkpiscJ25MRXmRxmIm3GH6xf0=";
  };

  postPatch = ''
    # Use nixpkgs electron instead of downloading
    substituteInPlace package.json \
      --replace-fail '"electron": "^34.1.1"' '"electron": "*"'

    # Disable code signing (not needed for Nix)
    substituteInPlace package.json \
      --replace-fail '"afterSign": "build/notarize.js",' ""

    # Fix app name and userData paths inside filen-desktop app source
    substituteInPlace src/index.ts \
      --replace-fail 'const options = await this.options.get()' \ '
      app.setName("${desktopName}")
      app.setPath("userData", pathModule.join(app.getPath("appData"), "@filen", "desktop"))
      const options = await this.options.get()
    '
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    copyDesktopItems
  ];

  buildInputs = [
    pixman
    cairo
    pango
  ];

  npmDepsHash = "sha256-+Ul2z6faZvAeCHq35janVTUNoqTQ5JNDeLbCV220nFU=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  buildPhase = ''
    runHook preBuild

    # Compile TypeScript
    npm run build

    # Prepare nixpkgs electron for electron-builder
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    # Build platform bundle
    npx electron-builder \
      --dir \
      --${if stdenv.hostPlatform.isDarwin then "mac" else "linux"} \
      -c.electronDist=electron-dist \
      -c.electronVersion="${electron.version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          # Install macOS .app bundle
          mkdir -p $out/Applications
          cp -r prod/mac*/${appName}.app $out/Applications/

          # Create bin symlink
          mkdir -p $out/bin
          makeWrapper "$out/Applications/${appName}.app/Contents/MacOS/${appName}" $out/bin/${packageName}
        ''
      else
        ''
          # Copy built resources
          mkdir -p $out/share/${packageName}
          cp -r prod/*-unpacked/{locales,resources{,.pak}} $out/share/${packageName}

          # Create desktop icon
          mkdir -p $out/share/icons/hicolor/128x128/apps
          cp assets/icons/app/linux.png $out/share/icons/hicolor/128x128/apps/${packageName}.png

          # Create launcher with electron
          makeWrapper ${lib.getExe electron} $out/bin/${packageName} \
            --set ELECTRON_IS_DEV 0 \
            --add-flags $out/share/${packageName}/resources/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
            --inherit-argv0
        ''
    }

    runHook postInstall
  '';

  desktopItems = lib.optionals (!stdenv.hostPlatform.isDarwin) [ desktopItem ];
  makeCacheWritable = true;

  meta = {
    description = "Filen Desktop Client";

    longDescription = ''
      Encrypted Cloud Storage built for your Desktop.
      Sync your data, mount network drives, collaborate with others and access files natively powered by robust encryption and seamless integration.
    '';

    homepage = "https://filen.io/products";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      smissingham
      kashw2
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = packageName;
    downloadPage = "https://filen.io/products/desktop";
  };
}
