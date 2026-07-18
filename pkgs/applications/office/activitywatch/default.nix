{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  nodejs_22,
  openssl,
  perl,
  pkg-config,
  python3,
  python3Packages,
  qtbase,
  qtsvg,
  replaceVars,
  rust-jemalloc-sys,
  rustPlatform,
  wrapQtAppsHook,
  xdg-utils,
}:

let
  version = "0.13.2";
  sources = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "ActivityWatch";
    repo = "activitywatch";
    rev = "v${version}";
    sha256 = "sha256-Z3WAg3b1zN0nS00u0zIose55JXRzQ7X7qy39XMY7Snk=";
  };
in
rec {
  aw-notify = python3Packages.buildPythonApplication {
    inherit version;
    pname = "aw-notify";
    src = "${sources}/aw-notify";

    patches = [
      # Backport desktop-notifier 6 / rubicon-objc 0.5 support.
      # https://github.com/ActivityWatch/aw-notify/pull/10
      ./aw-notify-desktop-notifier-6.patch
    ];

    build-system = [ python3Packages.poetry-core ];

    dependencies = with python3Packages; [
      aw-client
      desktop-notifier
    ];

    pyproject = true;
    pythonImportsCheck = [ "aw_notify" ];

    pythonRelaxDeps = [
      "desktop-notifier"
    ];

    meta = {
      description = "Desktop notification service for ActivityWatch";
      homepage = "https://github.com/ActivityWatch/aw-notify";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
      mainProgram = "aw-notify";
    };
  };

  aw-qt = python3Packages.buildPythonApplication {
    inherit version;
    pname = "aw-qt";
    src = "${sources}/aw-qt";

    nativeBuildInputs = [
      wrapQtAppsHook
    ];

    postInstall = ''
      install -D resources/aw-qt.desktop $out/share/applications/aw-qt.desktop

      # For the actual tray icon, see
      # https://github.com/ActivityWatch/aw-qt/blob/8ec5db941ede0923bfe26631acf241a4a5353108/aw_qt/trayicon.py#L211-L218
      install -D media/logo/logo.png $out/${python3.sitePackages}/media/logo/logo.png

      # For .desktop file and your desktop environment
      install -D media/logo/logo.svg $out/share/icons/hicolor/scalable/apps/activitywatch.svg
      install -D media/logo/logo.png $out/share/icons/hicolor/512x512/apps/activitywatch.png
      install -D media/logo/logo-128.png $out/share/icons/hicolor/128x128/apps/activitywatch.png
    '';

    preFixup = ''
      makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
      )
    '';

    build-system = [
      python3Packages.poetry-core
      python3Packages.setuptools
    ];

    dependencies = with python3Packages; [
      aw-core
      qtbase
      qtsvg # Rendering icons in the trayicon menu
      pyqt6
      click
    ];

    # Prevent double wrapping
    dontWrapQtApps = true;

    makeWrapperArgs = [
      "--suffix PATH : ${lib.makeBinPath [ xdg-utils ]}"
    ];

    pyproject = true;
    pythonImportsCheck = [ "aw_qt" ];

    meta = {
      description = "Tray icon that manages ActivityWatch processes, built with Qt";
      homepage = "https://github.com/ActivityWatch/aw-qt";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
      badPlatforms = lib.platforms.darwin; # requires pyobjc-framework
      mainProgram = "aw-qt";
    };
  };

  aw-server-rust = rustPlatform.buildRustPackage {
    inherit version;
    pname = "aw-server-rust";
    src = "${sources}/aw-server-rust";

    patches = [
      # Override version string with hardcoded value as it may be outdated upstream.
      (replaceVars ./override-version.patch {
        version = sources.rev;
      })
    ];

    nativeBuildInputs = [
      makeWrapper
      pkg-config
      perl
    ];

    buildInputs = [
      openssl
      rust-jemalloc-sys
    ];

    cargoHash = "sha256-E89E/LWBPHtb6vX94swodmE+UrWMrzQnm8AO5GeyuoA=";
    env.AW_WEBUI_DIR = aw-webui;

    preCheck = ''
      # Fake home folder for tests that use ~/.cache and ~/.local/share
      export HOME="$TMPDIR"
    '';

    meta = {
      description = "High-performance implementation of the ActivityWatch server, written in Rust";
      homepage = "https://github.com/ActivityWatch/aw-server-rust";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
      platforms = lib.platforms.linux;
      mainProgram = "aw-server";
    };
  };

  aw-watcher-afk = python3Packages.buildPythonApplication {
    inherit version;
    pname = "aw-watcher-afk";
    src = "${sources}/aw-watcher-afk";
    build-system = [ python3Packages.poetry-core ];

    dependencies = with python3Packages; [
      aw-client
      python-xlib
      pynput
    ];

    pyproject = true;
    pythonImportsCheck = [ "aw_watcher_afk" ];

    pythonRelaxDeps = [
      "python-xlib"
    ];

    meta = {
      description = "Watches keyboard and mouse activity to determine if you are AFK or not (for use with ActivityWatch)";
      homepage = "https://github.com/ActivityWatch/aw-watcher-afk";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
      mainProgram = "aw-watcher-afk";
    };
  };

  aw-watcher-window = python3Packages.buildPythonApplication {
    inherit version;
    pname = "aw-watcher-window";
    src = "${sources}/aw-watcher-window";
    build-system = [ python3Packages.poetry-core ];

    dependencies = with python3Packages; [
      aw-client
      python-xlib
    ];

    pyproject = true;
    pythonImportsCheck = [ "aw_watcher_window" ];

    pythonRelaxDeps = [
      "python-xlib"
    ];

    meta = {
      description = "Cross-platform window watcher (for use with ActivityWatch)";
      homepage = "https://github.com/ActivityWatch/aw-watcher-window";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
      badPlatforms = lib.platforms.darwin; # requires pyobjc-framework
      mainProgram = "aw-watcher-window";
    };
  };

  aw-webui = buildNpmPackage {
    inherit version;
    pname = "aw-webui";
    src = "${sources}/aw-server-rust/aw-webui";

    patches = [
      # Hardcode version to avoid the need to have the Git repo available at build time.
      (replaceVars ./commit-hash.patch {
        commit_hash = sources.rev;
      })
    ];

    npmDepsHash = "sha256-fPk7UpKuO3nEN1w+cf9DIZIG1+XRUk6PJfVmtpC30XE=";
    doCheck = true;

    checkPhase = ''
      runHook preCheck
      npm test
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      mv dist $out
      mv media/logo/logo.{png,svg} $out
      runHook postInstall
    '';

    makeCacheWritable = true;
    nodejs = nodejs_22;
    npmFlags = [ "--legacy-peer-deps" ];

    meta = {
      description = "Web-based UI for ActivityWatch, built with Vue.js";
      homepage = "https://github.com/ActivityWatch/aw-webui/";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ huantian ];
    };
  };
}
