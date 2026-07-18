{
  lib,
  adwaita-icon-theme,
  atk,
  fetchPypi,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  goocanvas_2,
  gtk3,
  gtkspell3,
  librsvg,
  pango,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tryton";
  version = "7.8.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-X8jJ/NXbvoKJdKep78inefILaFLjJyAmRMVfdOEb0tk=";
  };

  strictDeps = false;

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    adwaita-icon-theme
    goocanvas_2
    fontconfig
    freetype
    gtk3
    gtkspell3
    librsvg
    pango
  ];

  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    python-dateutil
    pygobject3
    goocalendar
    pycairo
  ];

  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "tryton" ];

  meta = {
    description = "Client of the Tryton application platform";

    longDescription = ''
      The client for Tryton, a three-tier high-level general purpose
      application platform under the license GPL-3 written in Python and using
      PostgreSQL as database engine.

      It is the core base of a complete business solution providing
      modularity, scalability and security.
    '';

    homepage = "http://www.tryton.org/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      johbo
      udono
    ];

    mainProgram = "tryton";
  };
})
