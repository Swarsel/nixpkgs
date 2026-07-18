{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron_41,
  httptoolkit-server,
  makeDesktopItem,
  makeWrapper,
  xcbuild,
}:

let
  electron = electron_41;
in
buildNpmPackage rec {
  pname = "httptoolkit";
  # update together with httptoolkit-server
  # nixpkgs-update: no auto update
  version = "1.26.0";

  src = fetchFromGitHub {
    owner = "httptoolkit";
    repo = "httptoolkit-desktop";
    tag = "v${version}";
    hash = "sha256-WEl0DGYdq1qa5zNEVO6L8TW6lgNTI0NdL0YXeR3Z0BI=";
  };

  patches = [
    ./fix-paths.patch
  ];

  postPatch = ''
    substituteInPlace httptoolkit-{mcp,ctl} src/index.ts \
      --replace-fail "@out@" "$out"
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild ];

  npmDepsHash = "sha256-fGVxHhJU/1ZsRyX3AnP6jM/jkY0PZHKDA1tb2z06lLs=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postBuild = ''
    cp -rL ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.mac.forceCodeSigning=false \
      -c.mac.identity=null
    # ^ this disables codesigning on Darwin
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share/httptoolkit
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/httptoolkit

    ln -s ${httptoolkit-server} $out/share/httptoolkit/resources/httptoolkit-server

    install -Dm644 src/icons/icon.svg $out/share/icons/hicolor/scalable/apps/httptoolkit.svg

    makeWrapper ${lib.getExe electron} $out/bin/httptoolkit \
      --add-flags $out/share/httptoolkit/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r dist/mac*/"HTTP Toolkit.app" $out/Applications

    ln -s ${httptoolkit-server} "$out/Applications/HTTP Toolkit.app/Contents/Resources/httptoolkit-server"

    makeWrapper "$out/Applications/HTTP Toolkit.app/Contents/MacOS/HTTP Toolkit" $out/bin/httptoolkit
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = meta.description;
      desktopName = "HTTP Toolkit";
      exec = "httptoolkit %U";
      icon = "httptoolkit";
      name = "httptoolkit";
      startupNotify = true;
      startupWMClass = "HTTP Toolkit";
      terminal = false;
    })
  ];

  makeCacheWritable = true;
  npmBuildScript = "build:src";

  meta = {
    description = "HTTP(S) debugging, development & testing tool";
    homepage = "https://httptoolkit.com/";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = electron.meta.platforms;
    mainProgram = "httptoolkit";
  };
}
