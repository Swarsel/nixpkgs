{
  lib,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  gtk3,
  keybinder3,
  libwnck,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dockbarx";
  version = "1.0-beta4";

  src = fetchFromGitHub {
    owner = "xuzhen";
    repo = "dockbarx";
    rev = finalAttrs.version;
    sha256 = "sha256-J/5KpHptGzgRF1qIGrgjkRR3in5pE0ffkiYVTR3iZKY=";
  };

  nativeBuildInputs = [
    glib.dev
    gobject-introspection
    python3Packages.polib
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libwnck
    keybinder3
  ];

  # no tests
  doCheck = false;

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    dbus-python
    pillow
    pygobject3
    pyxdg
    python-xlib
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Lightweight taskbar/panel replacement which works as a stand-alone dock";
    homepage = "https://github.com/xuzhen/dockbarx";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
