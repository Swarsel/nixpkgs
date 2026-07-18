{
  lib,
  fetchurl,
  adwaita-icon-theme,
  copyDesktopItems,
  fetchpatch,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  keybinder3,
  libappindicator,
  libnotify,
  librsvg,
  libx11,
  makeDesktopItem,
  nix-update-script,
  python3Packages,
  webkitgtk_4_1,
  wmctrl,
  wrapGAppsHook3,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ulauncher";
  version = "5.15.7";

  src = fetchurl {
    url = "https://github.com/Ulauncher/Ulauncher/releases/download/${finalAttrs.version}/ulauncher_${finalAttrs.version}.tar.gz";
    hash = "sha256-YgOw3Gyy/o8qorWAnAlQrAZ2ZTnyP3PagLs2Qkdg788=";
  };

  patches = [
    ./fix-path.patch
    ./fix-extensions.patch
    (fetchpatch {
      hash = "sha256-w1c+Yf6SA3fyMrMn1LXzCXf5yuynRYpofkkUqZUKLS8=";
      name = "support-gir1.2-webkit2-4.1.patch";
      url = "https://src.fedoraproject.org/rpms/ulauncher/raw/rawhide/f/support-gir1.2-webkit2-4.1.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py --subst-var out
    patchShebangs bin/ulauncher-toggle
    substituteInPlace bin/ulauncher-toggle \
      --replace-fail wmctrl ${wmctrl}/bin/wmctrl
  '';

  nativeBuildInputs = [
    gobject-introspection
    intltool
    wrapGAppsHook3
    gdk-pixbuf
    copyDesktopItems
  ];

  buildInputs = [
    glib
    adwaita-icon-theme
    gtk3
    keybinder3
    libappindicator
    libnotify
    librsvg
    webkitgtk_4_1
    wmctrl
  ];

  # https://github.com/Ulauncher/Ulauncher/issues/390
  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    mock
    pytest
    pytest-mock
    xvfb-run
  ];

  preCheck = ''
    export PYTHONPATH=$PYTHONPATH:$out/${python3Packages.python.sitePackages}
  '';

  # Simple translation of
  # - https://github.com/Ulauncher/Ulauncher/blob/f5a601bdca75198a6a31b9d84433496b63530e74/test
  checkPhase = ''
    runHook preCheck

    # skip tests in invocation that handle paths that
    # aren't nix friendly (i think)
    xvfb-run -s '-screen 0 1024x768x16' \
      pytest -k 'not TestPath and not test_handle_key_press_event' tests

    runHook postCheck
  '';

  preFixup = ''
    makeWrapperArgs+=(
     "''${gappsWrapperArgs[@]}"
     --prefix PATH : "${lib.makeBinPath [ wmctrl ]}"
     --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libx11 ]}"
     --prefix WEBKIT_DISABLE_COMPOSITING_MODE : "1"
    )
  '';

  build-system = with python3Packages; [
    setuptools
    distutils-extra
  ];

  dependencies = with python3Packages; [
    mock
    dbus-python
    pygobject3
    pyinotify
    levenshtein
    pyxdg
    pycairo
    requests
    semver
    websocket-client
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      desktopName = "Ulauncher";
      exec = "ulauncher";
      icon = "ulauncher";
      name = "ulauncher";
    })
  ];

  # do not double wrap
  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "ulauncher" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast application launcher for Linux, written in Python, using GTK";
    homepage = "https://ulauncher.io/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      aaronjanse
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ulauncher";
  };
})
