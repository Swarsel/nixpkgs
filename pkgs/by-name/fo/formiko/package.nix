{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  gtksourceview4,
  gtkspell3,
  librsvg,
  python3Packages,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "formiko";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "ondratu";
    repo = "formiko";
    tag = finalAttrs.version;
    hash = "sha256-slfpkckCvxHJ/jlBP7QAhzaf9TAcS6biDQBZcBTyTKI=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    gtk3
  ];

  buildInputs = [
    gobject-introspection
    gtk3
    gtksourceview4
    gtkspell3
    librsvg
    webkitgtk_4_1
  ];

  # Needs a display
  doCheck = false;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pygobject3
    python3Packages.docutils
  ];

  pyproject = true;

  meta = {
    description = "reStructuredText editor and live previewer";
    homepage = "https://github.com/ondratu/formiko";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
