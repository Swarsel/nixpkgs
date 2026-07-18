{
  lib,
  fetchFromGitHub,
  atk,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  itstool,
  pango,
  python3Packages,
  wafHook,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hamster";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "projecthamster";
    repo = "hamster";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-cUmUvJP9Y3de5OaNgIxvigDsX2ww7NNRY5son/gg+WI=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    wrapGAppsHook3
    intltool
    itstool
    wafHook
    glib
    gobject-introspection
  ];

  buildInputs = [
    pango
    gdk-pixbuf
    atk
    gtk3
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pycairo
    pyxdg
    setuptools
    dbus-python
  ];

  env.PYTHONDIR = "${placeholder "out"}/${python3Packages.python.sitePackages}";

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out ''${pythonPath[*]}"
  '';

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Time tracking application";
    homepage = "http://projecthamster.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.fabianhauser ];
    platforms = lib.platforms.all;
    mainProgram = "hamster";
  };
})
