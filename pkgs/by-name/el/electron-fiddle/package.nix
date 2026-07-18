{
  lib,
  fetchFromGitHub,
  buildFHSEnv,
  electron,
  fetchYarnDeps,
  git,
  makeDesktopItem,
  nodejs,
  stdenvNoCC,
  util-linux,
  yarnBuildHook,
  yarnConfigHook,
  zip,
}:

let
  pname = "electron-fiddle";
  version = "0.37.2";

  src = fetchFromGitHub {
    owner = "electron";
    repo = "fiddle";
    tag = "v${version}";
    hash = "sha256-e9PLgkqWBNLBw7uuNpPluOQ6+aGLYQLyTzcLa+LMOzs=";
  };

  patches = [
    ./dont-use-initial-releases-json.patch
    ./dont-fetch-contributors.patch

    # zip extraction fails on newer nodejs versions without this fix
    ./bump-yauzl.patch
  ];

  unwrapped = stdenvNoCC.mkDerivation {
    inherit version src patches;
    pname = "${pname}-unwrapped";

    nativeBuildInputs = [
      git
      nodejs
      util-linux
      yarnBuildHook
      yarnConfigHook
      zip
    ];

    # electron-forge's console output is squeezed into one narrow column if unset
    env.CI = "1";

    preBuild = ''
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
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/electron-fiddle/resources"
      cp "out/Electron Fiddle-"*/resources/app.asar "$out/lib/electron-fiddle/resources/"
      mkdir -p "$out/share/icons/hicolor/scalable/apps"
      cp assets/icons/fiddle.svg "$out/share/icons/hicolor/scalable/apps/electron-fiddle.svg"

      runHook postInstall
    '';

    offlineCache = fetchYarnDeps {
      inherit src patches;
      hash = "sha256-5yUsjXQ3OHwEGFgMTUJAXAuTdAl4zkb8zxTs5OT6sw4=";
    };

    yarnBuildScript = "package";
  };

  desktopItem = makeDesktopItem {
    categories = [
      "GNOME"
      "GTK"
      "Utility"
    ];

    comment = "The easiest way to get started with Electron";
    desktopName = "Electron Fiddle";
    exec = "electron-fiddle %U";
    genericName = "Electron Fiddle";
    icon = "electron-fiddle";
    mimeTypes = [ "x-scheme-handler/electron-fiddle" ];
    name = "electron-fiddle";
    startupNotify = true;
  };

in
buildFHSEnv {
  inherit pname version;

  extraInstallCommands = ''
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    ln -s "${unwrapped}/share/icons/hicolor/scalable/apps/electron-fiddle.svg" "$out/share/icons/hicolor/scalable/apps/"
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications"/*.desktop "$out/share/applications/"
  '';

  runScript = "${lib.getExe electron} ${unwrapped}/lib/electron-fiddle/resources/app.asar";

  targetPkgs =
    pkgs:
    with pkgs;
    map lib.getLib [
      # for electron-fiddle itself
      udev

      # for running Electron 22.0.0 inside
      alsa-lib
      atk
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libdrm
      libglvnd
      libnotify
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb

      # for running Electron before 18.3.5/19.0.5/20.0.0 inside
      gdk-pixbuf

      # for running Electron before 16.0.0 inside
      libxshmfence

      # for running Electron before 11.0.0 inside
      libxcursor
      libxi
      libxrender
      libxtst

      # for running Electron before 10.0.0 inside
      libxscrnsaver

      # for running Electron before 8.0.0 inside
      libuuid

      # for running Electron before 4.0.0 inside
      fontconfig

      # for running Electron before 3.0.0 inside
      gnome2.GConf

      # Electron 2.0.8 is the earliest working version, due to
      # https://github.com/electron/electron/issues/13972
    ];

  passthru = { inherit unwrapped; };

  meta = {
    description = "Easiest way to get started with Electron";
    homepage = "https://www.electronjs.org/fiddle";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      andersk
      tomasajt
    ];

    platforms = electron.meta.platforms;
    mainProgram = "electron-fiddle";
  };
}
