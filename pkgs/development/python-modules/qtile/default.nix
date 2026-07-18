{
  lib,
  fetchFromGitHub,
  # propagatedBuildInputs
  aiohttp,
  anyio,
  buildPythonPackage,
  # buildInputs
  cairo,
  # dependencies
  cairocffi,
  cffi,
  dbus-fast,
  fontconfig,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  # checkInputs
  gtk3,
  isort,
  iwlib,
  libcst,
  # environment & pypaBuildFlags
  libdrm,
  libinput,
  librsvg,
  libxcb-cursor,
  libxcb-wm,
  libxkbcommon,
  # passthru.tests
  nixosTests,
  pango,
  pixman,
  # nativeBuildInputs
  pkg-config,
  prompt-toolkit,
  psutil,
  pulsectl-asyncio,
  pygobject3,
  pytest-asyncio,
  pytest-httpbin,
  pytest-rerunfailures,
  pytest-xdist,
  # nativeCheckInputs
  pytestCheckHook,
  python-mpd2,
  pyxdg,
  # build-system
  setuptools,
  setuptools-scm,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots,
  writableTmpDirAsHomeHook,
  wxsvg,
  xcffib,
  xorg-server,
  xterm,
  xvfb,
  extraPackages ? [ ],
}:

buildPythonPackage (finalAttrs: {
  pname = "qtile";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "qtile";
    repo = "qtile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yFh9h3djV52zdZjPYwOWaMzN9ZNhFdZYyxFJreoJBCk=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    cairo
    libinput
    libxcb-wm
    libxkbcommon
    wayland
    wlroots
  ];

  propagatedBuildInputs = [
    wayland-protocols
  ];

  env = {
    "QTILE_CAIRO_PATH" = "${lib.getDev cairo}/include/cairo";
    "QTILE_LIBDRM_PATH" = "${lib.getDev libdrm}/include/libdrm";
    "QTILE_PIXMAN_PATH" = "${lib.getDev pixman}/include/pixman-1";

    "QTILE_WLROOTS_PATH" =
      "${lib.getDev wlroots}/include/wlroots-${lib.versions.majorMinor wlroots.version}";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-httpbin
    pytest-rerunfailures
    pytest-xdist
    writableTmpDirAsHomeHook
    anyio
    gdk-pixbuf
    gobject-introspection
    isort
    wxsvg
    xorg-server
    xterm
    xvfb
  ];

  checkInputs = [
    gtk3
    librsvg
  ];

  preCheck = ''
    export PATH=$PATH:$out/bin
  '';

  postInstall = ''
    install resources/qtile.desktop -Dt $out/share/xsessions
    install resources/qtile-wayland.desktop -Dt $out/share/wayland-sessions
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = extraPackages ++ [
    aiohttp
    (cairocffi.override { withXcffib = true; })
    cffi
    dbus-fast
    iwlib
    libcst
    python-mpd2
    # prompt-toolkit used for qtile repl
    # see https://github.com/qtile/qtile/blob/master/libqtile/scripts/repl.py
    prompt-toolkit
    psutil
    pulsectl-asyncio
    pygobject3
    pyxdg
    xcffib
  ];

  disabledTests = [
    # caused by dbus-fast trying to read '/var/lib/dbus/machine-id'
    "test_defaults"
    "test_device_actions"
    "test_adapter_actions"
    "test_statusnotifier_defaults"
    "test_custom_symbols"
    "test_statusnotifier_defaults_vertical_bar"
    "test_default_show_battery"
    "test_statusnotifier_icon_size"
    "test_missing_adapter"
    "test_statusnotifier_left_click"
    "test_default_text"
    "test_statusnotifier_left_click_vertical_bar"
    "test_default_device"

    # PermissionError: [Errno 13] Permission denied: '/var'
    "test_thermal_zone_getting_value"

    # Probably won't work in the Nix sandbox due to `xcffib.ConnectionException`
    "test_urgent_hook_fire"
  ];

  pypaBuildFlags = [
    "--config-setting=backend=wayland"
    "--config-setting=FONTCONFIG=${lib.getLib fontconfig}/lib/libfontconfig.so"
    "--config-setting=GOBJECT=${lib.getLib glib}/lib/libgobject-2.0.so"
    "--config-setting=PANGO=${lib.getLib pango}/lib/libpango-1.0.so"
    "--config-setting=PANGOCAIRO=${lib.getLib pango}/lib/libpangocairo-1.0.so"
    "--config-setting=XCBCURSOR=${lib.getLib libxcb-cursor}/lib/libxcb-cursor.so"
  ];

  # nixpkgs-update: no auto update
  # should be updated alongside with `qtile-extras`
  pyproject = true;

  pytestFlags = [
    "--reruns 3"
    "--reruns-delay 5"
  ];

  pythonImportsCheck = [ "libqtile" ];

  passthru = {
    providedSessions = [ "qtile" ];
    tests.qtile = nixosTests.qtile;
  };

  meta = {
    description = "Small, flexible, scriptable tiling window manager written in Python";
    homepage = "https://qtile.org/";
    changelog = "https://github.com/qtile/qtile/blob/v${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      arjan-s
      sigmanificient
      doronbehar
    ];

    platforms = lib.platforms.linux;
    mainProgram = "qtile";
  };
})
