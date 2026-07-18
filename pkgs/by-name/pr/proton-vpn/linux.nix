{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  libappindicator-gtk3,
  libayatana-appindicator,
  libnotify,
  meta,
  nix-update-script,
  python3Packages,
  wrapGAppsHook4,
  writableTmpDirAsHomeHook,
  withIndicator ? true,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "proton-vpn";
  version = "4.16.5";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "proton-vpn-gtk-app";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wClBUF5bz+bVt9w7LQGfU3mKnEtgax8GXnGNyH2/obU=";
  };

  nativeBuildInputs = [
    # Needed for the NM namespace
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libnotify # gir typelib is used
  ]
  ++ lib.optionals withIndicator [
    # Adds AppIndicator3 namespace
    libappindicator-gtk3
    # Adds AyatanaAppIndicator3 namespace
    libayatana-appindicator
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ]);

  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  postInstall = ''
    mkdir -p $out/share/applications

    # Fix the desktop file to correctly identify the wrapped app and show the icon during runtime
    substitute ${finalAttrs.src}/rpmbuild/SOURCES/proton.vpn.app.gtk.desktop $out/share/applications/proton.vpn.app.gtk.desktop \
      --replace-fail "StartupWMClass=protonvpn-app" "StartupWMClass=.protonvpn-app-wrapped"
    install -Dm444 ${finalAttrs.src}/rpmbuild/SOURCES/proton-vpn-logo.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    dbus-python
    packaging
    proton-core
    proton-keyring-linux
    proton-vpn-api-core
    proton-vpn-local-agent
    pycairo
    pygobject3
  ];

  disabledTestPaths = [
    # Segmentation fault during widgets tests
    "tests/unit/widgets"
    # Segmentation fault during GObject signal test
    "tests/unit/utils/test_safe_signal_connect.py"
  ];

  dontWrapGApps = true;
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = meta // {
    platforms = lib.platforms.linux;
    mainProgram = "protonvpn-app";
  };
})
