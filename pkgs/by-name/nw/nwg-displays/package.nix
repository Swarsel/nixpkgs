{
  lib,
  fetchFromGitHub,
  atk,
  gdk-pixbuf,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  pango,
  python3Packages,
  wlr-randr,
  wrapGAppsHook3,
  hyprlandSupport ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nwg-displays";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-displays";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f7x6PTsND0eprhqvIdkZdHujcCbkJnqoXIKeE0O/YPE=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    atk
    gdk-pixbuf
    gtk-layer-shell
    pango
    python3Packages.gst-python
    python3Packages.i3ipc
    python3Packages.pygobject3
  ]
  ++ lib.optionals hyprlandSupport [
    wlr-randr
  ];

  # Upstream has no tests
  doCheck = false;

  postInstall = ''
    install -Dm444 nwg-displays.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm444 nwg-displays.desktop -t $out/share/applications
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}");
  '';

  dontWrapGApps = true;
  format = "setuptools";

  meta = {
    description = "Output management utility for Sway, Hyprland and Niri";
    homepage = "https://github.com/nwg-piotr/nwg-displays";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qf0xb ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-displays";
  };
})
